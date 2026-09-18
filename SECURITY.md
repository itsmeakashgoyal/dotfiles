# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this repository, please open a [GitHub Issue](https://github.com/itsmeakashgoyal/dotfiles/issues) with the label `security`.

For sensitive disclosures, contact via GitHub private messaging.

---

## Secrets & Credentials in Dotfiles

This is a personal dotfiles repo. The following practices are enforced to prevent accidental credential exposure:

### What is gitignored

- `zsh/.config/zsh/conf.d/private.zsh` — machine-local secrets, API keys, work tokens
- Any `*.env` files
- SSH private keys

### Where to put secrets

**Always** use `private.zsh` for:
- API tokens (`GITHUB_TOKEN`, `OPENAI_API_KEY`, etc.)
- Work-specific environment variables
- Machine-specific PATH additions
- Credentials of any kind

See [`zsh/.config/zsh/conf.d/private.zsh.example`](zsh/.config/zsh/conf.d/private.zsh.example) for a template.

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

The included `dutils ssh-setup` (`scripts/dutils/ssh_setup.py`) generates **Ed25519** keys (preferred over RSA) for separate personal and work GitHub identities — see [docs/SSH.md](docs/SSH.md). After generation:

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

## macOS Package Install Script

`scripts/setup/macos.sh` installs Homebrew and every formula/cask listed in `brew/Brewfile`. Review the Brewfile before running on a fork — it installs packages system-wide.
