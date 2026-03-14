# Manual Setup Guide

These steps require action in the GitHub UI or external tools — they cannot be automated via scripts.

---

## 1. GitHub Repository Settings

### Add Repository Topics

Topics improve discoverability in GitHub search and the "Explore" feed.

Go to **github.com/itsmeakashgoyal/dotfiles** → gear icon next to "About" → add:

```
dotfiles  zsh  neovim  tmux  macos  linux  stow  homebrew  terminal  productivity
```

### Enable GitHub Discussions

Go to **Settings → Features → Discussions** → enable.

This gives users a place to ask questions without opening issues. Post a pinned "Show & Tell" thread for people to share their customizations.

### Add Repository Description

A short description appears in search results:

```
Modern dotfiles for macOS & Linux — Neovim, Zsh, Tmux, Git, managed with GNU Stow
```

### Add Social Preview Image

**Settings → Social preview** → upload a 1280×640px image.

Design tips:
- Dark background, your terminal screenshot or ASCII art
- Show key tools: Neovim, Zsh, Tmux icons or names
- Can be generated with [carbon.now.sh](https://carbon.now.sh) or Figma

---

## 2. Create a GitHub Release

Tag your current stable state as `v1.0.0`:

```bash
git tag -a v1.0.0 -m "Initial stable release"
git push origin v1.0.0
```

Then on GitHub: **Releases → Draft a new release** → select `v1.0.0` → paste the relevant section from `CHANGELOG.md` → publish.

Releases show up in the "Used by" section for other repos and signal that the project is production-ready.

---

## 3. Terminal Screenshots with VHS

See [`docs/SCREENSHOTS.md`](SCREENSHOTS.md) for the full guide.

Quick steps:

```bash
brew install vhs
mkdir -p docs/img docs/tapes
# write a .tape file (see SCREENSHOTS.md for examples)
vhs docs/tapes/prompt.tape
```

Then add the GIFs to the README — this is the highest-impact change for attracting stars.

---

## 4. Add Ghostty Configuration

[Ghostty](https://ghostty.org/) is the fastest-growing terminal in the macOS community. Adding a config file will attract that audience.

Create `ghostty/.config/ghostty/config`:

```ini
# Font
font-family = "JetBrainsMono Nerd Font"
font-size = 15

# Theme
theme = catppuccin-mocha

# Window
window-padding-x = 12
window-padding-y = 10
macos-titlebar-style = hidden

# Shell
shell-integration = zsh

# Performance
resize-overlay = never
```

Then stow it:

```bash
# Add to Makefile: STOW_PACKAGES := git zsh nvim tmux ohmyposh ghostty
make stow pkg=ghostty
```

---

## 5. Add WezTerm Configuration

[WezTerm](https://wezfurlong.org/wezterm/) is popular in the Neovim community.

Create `wezterm/.config/wezterm/wezterm.lua`:

```lua
local wezterm = require("wezterm")
local config = {}

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 15.0
config.color_scheme = "Catppuccin Mocha"
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = 12, right = 12, top = 10, bottom = 10 }

return config
```

---

## 6. Set Up `mise` for Tool Version Management

[mise](https://mise.jdx.dev/) replaces `pyenv`, `rbenv`, `nvm`, and similar per-language version managers with one tool.

```bash
brew install mise
```

Create `mise/.config/mise/config.toml`:

```toml
[tools]
python = "3.12"
node = "lts"
go = "latest"
ruby = "3.3"
```

Add to `zsh/.config/zsh/conf.d/exports.zsh`:

```zsh
# mise - tool version manager
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
fi
```

---

## 7. Sponsor Button

If you want a GitHub sponsor button:

Create `.github/FUNDING.yml`:

```yaml
github: itsmeakashgoyal
```

This adds a "Sponsor" button to your repo page.

---

## 8. Star History Badge

After your repo gains some stars, add a star history chart to the README using [star-history.com](https://star-history.com):

```markdown
[![Star History Chart](https://api.star-history.com/svg?repos=itsmeakashgoyal/dotfiles&type=Date)](https://star-history.com/#itsmeakashgoyal/dotfiles&Date)
```
