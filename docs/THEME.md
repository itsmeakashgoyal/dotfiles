# Theming (Tokyo Night, coordinated)

One palette — **Tokyo Night** — across the whole terminal toolchain, with a
light/dark switch. The trick that keeps it simple: the **terminal is the source
of truth**, and the CLI tools follow its ANSI palette, so switching is mostly
"switch the terminal + Neovim" and everything else matches for free.

## What follows what

| Tool | How it's themed |
| --- | --- |
| **ghostty** | `theme = dark:TokyoNight Night,light:TokyoNight Day` — follows the macOS appearance by default; `dutils theme` can pin it |
| **bat** | `BAT_THEME=ansi` — renders with the terminal's ANSI colours (matches in light *and* dark) |
| **fzf** | `FZF_DEFAULT_OPTS` uses ANSI colour indices, so the picker follows the terminal too |
| **delta** | `syntax-theme = base16-256` — already ANSI-following |
| **neovim** | `folke/tokyonight.nvim`; `current-theme.lua` picks `tokyonight-day`/`-night` from the switch |
| **starship** | left intentionally monochrome/dimmed — palette-neutral, looks right on any background |
| **yazi** | left on its built-in theme (works on any background) |

## Switch it

```bash
dutils theme            # status (default) — show the current mode
dutils theme dark       # pin dark  (TokyoNight Night)
dutils theme light      # pin light (TokyoNight Day)
dutils theme toggle     # flip dark ↔ light
dutils theme auto       # follow the macOS light/dark appearance (default)
```

- **auto** (the default) means ghostty tracks the macOS system appearance — flip
  macOS to light/dark and the terminal + CLI tools follow. Neovim uses the dark
  (night) variant in auto mode.
- **dark/light** pin the theme regardless of the OS by writing
  `~/.config/ghostty/theme.local` (a gitignored, per-machine optional include)
  and `~/.config/dotfiles/theme` (read by Neovim).

After switching, **reload ghostty** (open a new window) and restart nvim / your
shells to pick up the change. bat/fzf/delta update as soon as the terminal does.

## Adding another palette later

The mechanism isn't Tokyo-Night-specific: point ghostty at another built-in
theme (`ghostty +list-themes`), add the matching `*.nvim` colorscheme, and the
ANSI-following tools come along automatically. `dutils theme` currently curates
Tokyo Night dark/light; extend `scripts/dutils/theme.py` to add more.
