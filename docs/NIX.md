# Nix on Linux (package manager)

On **Linux/Ubuntu**, [Nix](https://nixos.org/) + [Home Manager](https://nix-community.github.io/home-manager/)
replace **linuxbrew** as the package installer. It is declarative, reproducible,
and ships fresh tool versions — the same reason you used Homebrew, without
linuxbrew's glibc friction and shell-startup overhead.

**Scope (deliberately minimal):** Nix manages *packages only*. Your dotfiles
(zsh, nvim, tmux, …) are still symlinked by **GNU Stow**, and your shell config
is still driven by **Zinit + Powerlevel10k**. Nix does not touch any of that.

**macOS is unchanged** — it keeps using Homebrew (`packages/Brewfile`) and Stow.

```text
nix/
├── flake.nix     # inputs (nixpkgs + home-manager) + users list / arch
├── home.nix      # the package list — your Brewfile's CLI tools, in Nix
└── flake.lock    # auto-generated version pins (commit this)
```

**This is the default Linux flow.** `make install` on Linux now installs CLI
tools via Nix (linuxbrew is no longer used on Linux). On macOS, `make install`
is unchanged and still uses Homebrew.

---

## First-time setup (Ubuntu)

The normal installer handles it — on Linux, `make install` runs apt (system
deps only) then Nix + Home Manager for all CLI tools:

```bash
cd ~/dotfiles

# 1. Make sure your Linux $USER is in the flake's users list.
#    Edit nix/flake.nix (architecture is auto-detected — no system line):
#      users = [ "akashgoyal" "runner" "<your $USER>" ];

# 2. Run the installer (Linux → Nix path automatically)
make install

# 3. Open a new shell so the Nix profile is on PATH
exec zsh
```

> **Architecture is auto-detected.** The flake builds configs for both
> `x86_64-linux` and `aarch64-linux`, named `<user>-<system>` (e.g.
> `runner-x86_64-linux`). `make nix-*` and `scripts/setup/nix.sh` pick the
> right one from `uname -m`, so the same flake works on Intel/AMD and ARM
> machines and on CI with no edits.

To (re)apply just the Nix package set without the full installer:

```bash
make nix-setup     # installs Nix if missing, then home-manager switch
```

`make nix-setup` uses the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)
(flakes enabled by default, clean uninstall), then runs `home-manager switch`.
It refuses to run on macOS, auto-detects your architecture from `uname -m`, and
verifies your `$USER` is in the flake's `users` list before doing anything.

---

## Daily workflow

| Task | Command |
| --- | --- |
| Add/remove a tool | edit `nix/home.nix`, then `make nix-switch` |
| Update all versions | `make nix-update` (runs `nix flake update` + switch) |
| Roll back a bad change | `home-manager generations` then activate an older one |
| List installed | `home-manager packages` |

## Installing & uninstalling individual packages

This setup is **declarative**: you don't run `nix install <pkg>` imperatively.
Instead you edit the package list in [`nix/home.nix`](../nix/home.nix) and apply
it. Adding a line installs a package; removing the line uninstalls it. This keeps
your machine reproducible — the file is the single source of truth.

### Install a package

1. Find its attribute name at <https://search.nixos.org/packages>
   (search the tool, e.g. "dust", and copy the **package name**).
2. Add it to the `home.packages` list in `nix/home.nix`:

   ```nix
   home.packages = with pkgs; [
     # … existing tools …
     dust          # du replacement
     procs         # ps replacement
   ];
   ```

3. Apply the change:

   ```bash
   make nix-switch
   ```

4. The new commands are immediately available (open a new shell if a freshly
   added tool isn't found):

   ```bash
   dust --version
   ```

### Uninstall a package

1. Delete (or comment out) its line in `home.packages`:

   ```nix
   home.packages = with pkgs; [
     # … existing tools …
     # dust        # ← removed
     procs
   ];
   ```

2. Apply the change — Home Manager removes it from your profile:

   ```bash
   make nix-switch
   ```

   `dust` is now gone from `PATH`. Nothing else is affected.

### Try a package without installing it permanently

To run a tool **once** (or test it) without editing `home.nix`, use an ad-hoc
shell — it's available only for that session and leaves no trace:

```bash
nix shell nixpkgs#dust          # drops you in a shell with `dust` available
dust                            # use it
exit                            # gone — not installed

# or run a single command directly:
nix run nixpkgs#dust -- --help
```

### Imperative install (not recommended here)

Nix also supports imperatively installing into your profile:

```bash
nix profile install nixpkgs#dust     # install
nix profile list                     # see what's installed
nix profile remove dust              # uninstall
```

This works, but packages added this way **aren't tracked in `home.nix`**, so they
won't reproduce on another machine and won't show in version control. Prefer the
declarative `home.nix` + `make nix-switch` flow above; reserve `nix shell` /
`nix run` for one-off experimentation.

---

## Package mapping (Brewfile → Nix)

Most names match. The ones that differ:

| Homebrew | Nix attribute | Note |
| --- | --- | --- |
| `git-delta` | `delta` | |
| `tldr` | `tealdeer` | Rust client; provides the `tldr` command |
| `television` | `television` | In nixpkgs — no more `.deb` hack on Linux |
| fonts (casks) | `nerd-fonts.*` | Commented out in `home.nix`; enable if wanted |

macOS-only casks (fonts, `sshs`) are intentionally absent — they stay in the
Brewfile for the Mac.

---

## How the install flow splits by OS

`install.sh` branches at the package step:

| OS | Packages | System deps | Symlinks |
| --- | --- | --- | --- |
| **macOS** | Homebrew (`packages/install.sh` + `Brewfile`) | — | Stow |
| **Linux** | **Nix + Home Manager** (`nix/`) | apt (`scripts/setup/linux.sh`) | Stow |

On Linux, `scripts/setup/linux.sh` installs *only* system-level apt deps
(build-essential, stow, zsh, curl, fontconfig, …); all CLI tools come from Nix.
linuxbrew is no longer installed on Linux.

### Migrating an existing linuxbrew machine

If a machine still has linuxbrew from an older setup, remove it after confirming
the Nix tools are on PATH (`exec zsh`, then `which eza bat rg`):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

The dotfiles no longer reference it, so this is safe once Nix is active.

---

## Uninstalling Nix entirely

The Determinate installer supports a clean removal:

```bash
/nix/nix-installer uninstall
```

This removes `/nix`, the daemon, and the profile. Your dotfiles (Stow symlinks)
and linuxbrew are unaffected.

---

## Migrating macOS later (future)

When you're ready to unify both machines:

- Add `"aarch64-darwin"` (Apple Silicon) to the `systems` list in `flake.nix`
  — the `<user>-<system>` configs generate automatically — **or** adopt
  [nix-darwin](https://github.com/LnL7/nix-darwin) for system-level macOS bits.
- The same `home.nix` package list can be shared across both via a small
  refactor (split common vs per-OS packages).
- Decide then whether to also move dotfiles from Stow → Home Manager
  (`mkOutOfStoreSymlink` keeps live-editing working).

Not needed now — the Linux setup stands on its own.

---

## Troubleshooting

**`nix: command not found` right after install**
→ Open a new shell, or `source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`.

**`error: path '/nix/store/…' does not exist` / flake can't see files**
→ Flakes only read git-tracked files. Run `git add nix/` (the setup script does
this automatically) and retry.

**`error: flake output attribute 'homeConfigurations.<name>' does not exist`**
→ Your `$USER` isn't in the `users` list in `nix/flake.nix`. Add it:
`users = [ "akashgoyal" "runner" "<your $USER>" ];`

**Wrong architecture**
→ Auto-detected from `uname -m`; the flake builds for both `x86_64-linux` and
`aarch64-linux`. If you hit an unsupported arch, add it to the `systems` list in
`nix/flake.nix`.

**A package isn't found**
→ Search the exact attribute at <https://search.nixos.org/packages>; names
sometimes differ from Homebrew (see the mapping table above).
