# Contributing

Thank you for your interest in contributing! This is a personal dotfiles repository, but improvements, bug fixes, and new tool configurations are welcome.

---

## Ways to Contribute

- **Bug reports** — Something broken after following the README? Open an issue.
- **New Stow packages** — Add support for a tool not yet covered (e.g., `ghostty`, `wezterm`, `starship`).
- **Improvements** — Better aliases, smarter functions, CI improvements.
- **Documentation** — Clearer explanations, missing steps, new guides.

---

## Development Workflow

### 1. Fork & clone

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/dotfiles-dev
cd ~/dotfiles-dev
```

### 2. Install pre-commit hooks

```bash
pip install pre-commit
pre-commit install
```

This runs shellcheck and shfmt automatically before each commit.

### 3. Make your changes

#### Adding a new Stow package

Each package follows the same pattern — mirror the target path under a top-level directory:

```
dotfiles/
└── <toolname>/
    └── .config/
        └── <toolname>/
            └── config_file
```

Then register it in the `Makefile`:

```makefile
STOW_PACKAGES := git zsh nvim tmux ohmyposh <toolname>
```

And stow it:

```bash
make stow pkg=<toolname>
```

#### Modifying Zsh config

- Add aliases → `zsh/.config/zsh/conf.d/aliases.zsh`
- Add shell functions → `zsh/.config/zsh/conf.d/functions.zsh`
- Add environment variables → `zsh/.config/zsh/conf.d/exports.zsh`
- Machine-local changes → `zsh/.config/zsh/conf.d/private.zsh` (gitignored, never commit)

#### Modifying scripts

All scripts must:
- Start with `#!/bin/bash`
- Use `set -euo pipefail`
- Source `scripts/utils/_helper.sh` for logging
- Pass `shellcheck -x` with no errors

### 4. Test locally

```bash
# Lint all scripts
shellcheck -x scripts/**/*.sh install.sh bootstrap.sh

# Check shell formatting
shfmt -d scripts/

# Run health check
make health

# Full verification
make check
```

### 5. Commit

Follow conventional commits:

```
feat: add ghostty config package
fix: correct PATH order in exports.zsh
docs: add vhs recording guide
chore: update Brewfile with new tools
```

### 6. Open a Pull Request

- Target the `master` branch
- Fill in the PR template
- CI must pass (lint + macOS + Ubuntu tests)

---

## Code Style

### Shell scripts

- 4-space indentation
- `snake_case` for variable and function names
- Always quote variables: `"$variable"` not `$variable`
- Use `log_message`, `info`, `success`, `warning`, `error` from `_helper.sh` for output — never raw `echo` for status messages

### Makefile

- Group related targets under `##@` sections
- Every public target must have a `## Description` comment (used by `make help`)

### Markdown

- One sentence per line in prose (easier diffs)
- Code blocks always have a language tag

---

## What Won't Be Merged

- Changes that hardcode my personal details (name, email, GitHub handle) — those stay in `git/.config/git/config`
- New GUI app casks without a clear reason
- Large binary files
- Secrets of any kind
