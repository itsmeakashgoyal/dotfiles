# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this repository, please open a [GitHub Issue](https://github.com/itsmeakashgoyal/dotfiles/issues) with the label `security`.

For sensitive disclosures, contact via GitHub private messaging.

---

## Secrets & Credentials in Dotfiles

This is a personal dotfiles repo. The following practices are enforced to prevent accidental credential exposure:

### What is gitignored

- `zsh/.config/zsh/conf.d/99-private.zsh` (and `windows/.../profile.d/99-private.ps1`) — machine-local work exports, API keys, tokens. Kept owner-only (`chmod 600`; `.zshrc` re-applies it) and never compiled to `.zwc`
- Git identities (`~/.config/dotfiles/git/`, written by `dutils git-setup`) live outside the repo entirely
- Any `*.env` files
- SSH private keys

### Where to put secrets

**Always** use `99-private.zsh` for:
- API tokens (`GITHUB_TOKEN`, `OPENAI_API_KEY`, etc.)
- Work-specific environment variables
- Machine-specific PATH additions
- Credentials of any kind

`dutils init` creates a starter `99-private.zsh` with the right permissions.

### What NOT to commit

- Private SSH keys (`~/.ssh/id_*` — never add to dotfiles)
- `.netrc` files
- Browser cookies or session tokens
- Cloud provider credentials (`~/.aws/credentials`, `~/.gcloud/`)
- Database passwords

### Git pre-commit protection

The `.pre-commit-config.yaml` in this repo includes `detect-secrets` and `detect-private-key` hooks to catch accidental credential commits.

To install pre-commit hooks locally:

```bash
pip install pre-commit
pre-commit install
```

---

## SSH Key Hardening

The included `dutils git-setup` (`scripts/dutils/git_setup.py`) generates **Ed25519** keys (preferred over RSA) for separate personal and work GitHub identities — see [docs/SSH.md](docs/SSH.md). After generation:

1. Add a passphrase to your key
2. Use `ssh-agent` or macOS Keychain to avoid re-entering it
3. Never share your private key

```bash
# Generate key with passphrase
ssh-keygen -t ed25519 -C "your@email.com"

# Add to macOS Keychain
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

---

## Secrets Management

Secrets are kept **encrypted in the repo** with [`age`](https://age-encryption.org),
using your SSH key as the identity — see [docs/SECRETS.md](docs/SECRETS.md).

- Plaintext never lives in the repo; only `*.age` blobs and public `.recipients`
  are committed, and `secrets/.gitignore` blocks anything unencrypted.
- `detect-secrets` (pre-commit) is the backstop that catches secrets
  accidentally added *outside* `secrets/`.

```bash
dutils secrets init            # seed recipients from your SSH public key
dutils secrets add ~/.ssh/config
dutils secrets decrypt --all   # restore on a new machine
```

---

## Dependency Vulnerability Scanning

On macOS, `dutils vulns` scans installed Homebrew packages for known CVEs using
Homebrew 7.0+'s built-in `brew vulns` (OSV.dev-backed advisory database).

```bash
dutils vulns                    # all findings
dutils vulns --severity high    # only high+ severity
```

`dutils diagnose` also prints a one-line summary of findings. This is a local,
on-demand check — deliberately **not** a CI gate, since the advisory database
changes over time and would fail unrelated builds on newly disclosed CVEs.

---

## macOS Package Install Script

`scripts/setup/macos.sh` installs Homebrew and every formula/cask listed in `brew/Brewfile`. Review the Brewfile before running on a fork — it installs packages system-wide.
