# SSH keys & multi-account Git identity

Cross-platform (macOS / Linux / Windows) setup for using **separate GitHub
identities** — personal and company/professional — from one machine, with the
right commit email and the right SSH key chosen automatically per repo.

The whole thing hangs on one idea: **an SSH `Host` alias per account.** You
clone/push through the alias, and both the SSH key *and* the git commit email
follow from it. No per-repo `git config user.email`, no per-machine hand-edits.

```text
git@github-private:you/repo.git   → personal key  + gmail identity
git@github.com:org/repo.git       → default key   + work identity (machine default)
```

---

## One command: `dutils ssh-setup`

Cross-platform (Python — works on Windows too, which has no bash):

```bash
dutils ssh-setup                       # interactive: personal / work / both
dutils ssh-setup --profile personal -e you@gmail.com
dutils ssh-setup --profile work -e you@company.com --name "Your Name"
dutils ssh-setup --all                 # set up both, prompting per profile
```

`ssh-keygen` is kept as a back-compat alias of `ssh-setup`.

For each profile it:

1. **Generates an Ed25519 key** at `~/.ssh/<key-name>` (only if missing — it
   never clobbers an existing key), and sets `600`/`644` perms on POSIX. On
   Windows, OpenSSH uses NTFS ACLs, so a key created under your own profile is
   already private.
2. **Writes an idempotent `Host` block** into `~/.ssh/config` (re-running
   updates its own block in place, delimited by `# >>> dutils ssh-setup` markers
   — it never duplicates or touches hand-written entries).
3. **Adds the key to the agent** (best effort; on macOS with `--apple-use-keychain`).
4. **Prints the public key and copies it to the clipboard** so you can paste it
   into GitHub → *Settings → SSH and GPG keys* for the matching account.

Built-in profiles:

| Profile | Host alias | Key file | Git identity |
| --- | --- | --- | --- |
| `personal` | `github-private` | `~/.ssh/id_ed25519_private` | gmail, via the includeIf below |
| `work` | `github-work` | `~/.ssh/id_ed25519_work` | machine default (config-local) |

Override any of it with `--alias`, `--key-name`, `--host` (e.g. an enterprise
GitHub host), `--key-type rsa`, `-y` (non-interactive), `--no-clipboard`.

---

## How the git identity follows the remote

The tracked git config ([`git/.config/git/config`](../git/.config/git/config))
sets a **safe personal default** and layers overrides in this order (last match
wins per key):

```gitconfig
[user]
	name  = Akash Goyal
	email = ag.akgoyal@gmail.com        # public-safe default

[include]
	path = ~/.config/git/config-local   # per-machine work default (gitignored)

[includeIf "gitdir:~/personal/"]
	path = ~/.config/git/config-personal # gmail, for ~/personal/ repos

[includeIf "hasconfig:remote.*.url:git@github-private:*/**"]
	path = ~/.config/git/config-personal # gmail, for any github-private remote
```

Result, on any machine:

| Repo | Resolves to | Why |
| --- | --- | --- |
| remote `git@github-private:*` (incl. this dotfiles repo) | **gmail** | `hasconfig` includeIf, last match wins |
| any repo, when `config-local` exists (work machine) | **work email** | `[include] config-local` overrides the default |
| any repo, no `config-local` (personal machine) | **gmail** | tracked default; missing include is ignored |

- **`config-personal`** is tracked (gmail is fine to be public).
- **`config-local`** is **gitignored** and written per-machine by
  `dutils ssh-setup` (work profile). Because it's the machine *default*, it
  catches work repos cloned with ordinary `github.com`/enterprise remotes — the
  common case a remote-alias rule can't see. It never leaks a work email into
  the public repo, and every machine stays generic (no hand-edits to tracked
  files). `hasconfig:remote.*.url` requires **git ≥ 2.36**.

Check what a repo will use:

```bash
git config user.email
git config --show-origin user.email   # which file decided it
```

---

## Pointing an existing repo at an identity

```bash
# make this repo push as personal
git remote set-url origin git@github-private:you/repo.git

# make this repo push as work
git remote set-url origin git@github-work:org/repo.git
```

Nothing else to change — the key and the commit email both follow the alias.

---

## Platform notes

- **macOS / Linux** — `~/.ssh/config` and `~/.config/git/` are Stow-managed;
  keys and `config-local` are machine-local (never committed).
- **Windows** — `scripts/setup/windows.ps1` symlinks `~/.config/git`, so the
  same git config (and `config-local`) apply. `~/.ssh/config` works with the
  built-in OpenSSH client. If `ssh-add` can't reach an agent, start it once:
  ```powershell
  Set-Service ssh-agent -StartupType Automatic
  Start-Service ssh-agent
  ```

---

## Verifying a key works

```bash
ssh -T git@github-private     # → "Hi <you>! You've successfully authenticated…"
ssh -T git@github-work
```
