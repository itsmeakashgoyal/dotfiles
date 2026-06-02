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
├── flake.nix     # inputs (nixpkgs + home-manager) + your username/arch
├── home.nix      # the package list — your Brewfile's CLI tools, in Nix
└── flake.lock    # auto-generated version pins (commit this)
```

---

## First-time setup (Ubuntu)

```bash
cd ~/dotfiles

# 1. Edit two lines in nix/flake.nix to match your machine:
#      username = "<your $USER>";
#      system   = "x86_64-linux";   # or "aarch64-linux" on ARM

# 2. Install Nix + apply the package set
make nix-setup

# 3. Open a new shell so the Nix profile is on PATH
exec zsh
```

`make nix-setup` uses the [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)
(flakes enabled by default, clean uninstall), then runs the first
`home-manager switch`. The script refuses to run on macOS and validates your
username/arch against `flake.nix` before doing anything.

linuxbrew keeps working throughout — this is **additive**. Remove linuxbrew only
once you're happy (see below).

---

## Daily workflow

| Task | Command |
| --- | --- |
| Add/remove a tool | edit `nix/home.nix`, then `make nix-switch` |
| Update all versions | `make nix-update` (runs `nix flake update` + switch) |
| Roll back a bad change | `home-manager generations` then activate an older one |
| List installed | `home-manager packages` |

### Adding a package

1. Find its attribute name at <https://search.nixos.org/packages>.
2. Add it to the `home.packages` list in [`nix/home.nix`](../nix/home.nix).
3. `make nix-switch`.

Example — add `dust` and `procs`:

```nix
home.packages = with pkgs; [
  # … existing …
  dust
  procs
];
```

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

## How this coexists with the old flow

`make install` still runs the legacy Linux path (`packages/install.sh` →
linuxbrew, `scripts/setup/linux.sh` → apt). Nix is **opt-in via `make nix-setup`**
and does not modify those scripts. The two can run side by side; PATH precedence
decides which `eza`/`bat`/etc. you get (Nix's `~/.nix-profile/bin` typically wins
once the HM profile is sourced).

### Once you're happy — retiring linuxbrew on Linux

1. Confirm everything you need is in `nix/home.nix` and on PATH after `exec zsh`.
2. Uninstall linuxbrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
   ```
3. Optionally trim the manual tool installs (`install_eza`, `install_zoxide`,
   `install_cargo`, television `.deb`) from `scripts/setup/linux.sh`, and gate
   `packages/install.sh` to macOS only.

> Leave this until Nix has proven itself — there's no rush, and keeping both
> working is the safe state.

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

- Add `system = "aarch64-darwin"` (Apple Silicon) and a matching
  `homeConfigurations` entry, **or** adopt
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
→ The `username` in `nix/flake.nix` doesn't match `$USER`. Fix that one line.

**Wrong architecture**
→ Set `system = "aarch64-linux"` in `flake.nix` on ARM machines.

**A package isn't found**
→ Search the exact attribute at <https://search.nixos.org/packages>; names
sometimes differ from Homebrew (see the mapping table above).
