# Theme: Gruvbox everywhere

One palette ([Gruvbox](https://github.com/morhetz/gruvbox), medium contrast)
across every tool, **Gruvbox Dark by default** everywhere: iTerm2 and
everything inside it, plus Sublime Text. The terminal can be switched to light
or set to follow the OS with `dutils theme`; Sublime is a one-line change (see
below).

```bash
dutils theme            # status
dutils theme dark       # terminal: Gruvbox Dark (default)
dutils theme light      # terminal: Gruvbox Light
dutils theme auto       # terminal follows the OS too (iTerm2 swaps colours live)
dutils theme toggle     # dark ↔ light
dutils theme apply      # re-render from the saved mode (used by the installer)
```

The mode is stored in `~/.config/dotfiles/theme` (per machine, outside the
repo). iTerm2 updates immediately; open a new shell and restart Neovim for the
rest.

## What reads it

| Tool | How |
|---|---|
| iTerm2 | `dutils theme` renders `settings/iterm/profile.json` + Gruvbox colours into a Dynamic Profile. In `auto` mode the profile carries separate light and dark colours |
| zsh | `01-exports.zsh` resolves the mode once into `$DOTFILES_THEME=dark\|light`. In `auto` mode that costs one `defaults read` |
| bat, delta | `$BAT_THEME=gruvbox-dark\|gruvbox-light`; the git config sets no `syntax-theme`, so delta follows it |
| starship | Dark: `palette = "gruvbox_dark"`. Light: `.zshrc` points `STARSHIP_CONFIG` at a cached copy using `gruvbox_light`. Both palettes live in `starship.toml` |
| Neovim | `current-theme.lua`: gruvbox.nvim with `background` taken from `$DOTFILES_THEME`. In `auto` mode Neovim detects the terminal background itself |
| tmux, fzf, yazi | ANSI colour indices, so they follow the terminal palette automatically |
| Sublime Text | `Gruvbox Dark` scheme + Adaptive theme with a Gruvbox tab bar. `Gruvbox Light` ships too: set `"theme"` and `"color_scheme"` to `"auto"` in `Preferences.sublime-settings` to follow the OS |
| Windows | Windows Terminal "Gruvbox Dark" scheme, PSReadLine colours, `$BAT_THEME=gruvbox-dark` |
| television | `theme = "gruvbox-dark"` |
