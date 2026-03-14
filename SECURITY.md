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

The included `scripts/utils/_setup_ssh.sh` generates **Ed25519** keys (preferred over RSA). After generation:

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

## macOS System Preferences Script

`scripts/setup/_macOS.sh` modifies system preferences (Finder, Dock, keyboard). Review it before running — it is not reversible without a fresh macOS install of those defaults.
