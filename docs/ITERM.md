# iTerm2

iTerm2 is configured through a **Dynamic Profile**, not a synced preferences
plist. The plist approach changed on every launch, hardcoded the username, and
produced unreadable diffs.

```bash
make iterm      # or: bash scripts/setup/iterm.sh  (quit iTerm2 first, run from Terminal.app)
```

| Piece | Where |
|---|---|
| Profile settings (font, keys, triggers, hotkey window) | `settings/iterm/profile.json`: readable JSON, edit and run `dutils theme apply` |
| Colours | Gruvbox, added by `dutils theme` (see [THEME.md](THEME.md)) |
| Rendered profile | `~/Library/Application Support/iTerm2/DynamicProfiles/dotfiles-gruvbox.json` (iTerm2 hot-reloads it) |
| Global preferences | A short `defaults write` list in `scripts/setup/iterm.sh` |
| Shell integration | Copied from the app bundle; sourced by `conf.d/16-iterm.zsh` |

## What you get

- **Gruvbox** profile (the default): JetBrainsMono Nerd Font, unlimited
  scrollback, mouse reporting, no bell.
- **Gruvbox Hotkey** profile: a Quake-style drop-down terminal on **⌥Space**
  from any app or Space. It slides down from the top, floats over full-screen
  apps and auto-hides when it loses focus.
- **Natural text editing:**
  - ⌥←/⌥→ jump by word
  - ⌘←/⌘→ go to line start/end
  - ⌥⌫ deletes a word
  - ⌘⌫ deletes to line start
- **Left ⌥ acts as Meta** (Esc+), so Alt bindings work in zsh, tmux and Neovim.
  Right ⌥ still types special characters.
- **Light/dark:** with `dutils theme auto`, iTerm2 switches between Gruvbox Light
  and Dark with the OS.
- **Global settings:**
  - Minimal tab style, so the tab bar takes the Gruvbox background.
  - `tmux -CC` windows open as native tabs.
  - Copy on select.
- Your existing Claude Code workgroup triggers are kept.

## Migration (one time)

`iterm.sh` detects the old "load preferences from the dotfiles folder" setup.
It imports that plist into iTerm2's normal preferences (nothing is lost),
switches the custom folder off, and makes **Gruvbox** the default profile.
That step only runs while iTerm2 is **not** running, because iTerm2 rewrites
its preferences on quit. The Dynamic Profile itself is safe to install at any
time.

Afterwards `settings/iterm/com.googlecode.iterm2.plist` is untracked and can be
deleted.
