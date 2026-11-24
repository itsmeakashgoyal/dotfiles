# Security

**Reporting:** open a [GitHub issue](https://github.com/itsmeakashgoyal/dotfiles/issues) labelled `security`,
or message me privately on GitHub for anything sensitive.

## Keeping secrets out of this repo

| Put it in | For |
| --- | --- |
| `zsh/.config/zsh/conf.d/99-private.zsh` (Windows: `profile.d/99-private.ps1`) | Work exports, API tokens, machine-specific PATH. Gitignored, owner-only (`chmod 600` re-applied on shell start), never compiled to `.zwc` |
| `~/.config/dotfiles/git/` via `dutils git-setup` | Git names/emails, SSH key choice, signing (outside the repo) |
| `secrets/*.age` via `dutils secrets add` | Files you want versioned but encrypted (age + your SSH key) |

Never commit: SSH private keys, `.netrc`, cloud credentials (`~/.aws`, `~/.config/gcloud`), tokens, `.env` files.

Safety nets: `.gitignore` blocks the files above; the `detect-secrets` pre-commit hook
(`pre-commit install`) scans staged changes.
