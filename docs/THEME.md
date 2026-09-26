# Theming (Tokyo Night, coordinated — except Neovim, see below)

One palette — **Tokyo Night** — across the terminal toolchain, with a
light/dark switch. The trick that keeps it simple: the **terminal is the source
of truth**, and the CLI tools follow its ANSI palette, so switching is mostly
"switch the terminal" and everything else matches for free.

**Neovim is the one exception**: it now defaults to **gruvbox** (`current-theme.lua`
tries `gruvbox` first, falling back to `tokyonight-day`/`-night` only if
gruvbox.nvim fails to load), so it no longer visually matches ghostty's Tokyo
Night by default. The light/dark switch below still works for Neovim — it just
toggles gruvbox's light/dark variant (`vim.o.background`) instead of switching
colorscheme names. If you want Neovim back on Tokyo Night to match the
terminal again, swap gruvbox/tokyonight's roles in `current-theme.lua` and
`colorscheme.lua`/`tokyonight.lua` (`lazy = false` needs to move with
whichever one is primary — see the comments in those files for why).

## What follows what

| Tool | How it's themed |
| --- | --- |
| **ghostty** | `theme = dark:TokyoNight Night,light:TokyoNight Day` — follows the macOS appearance by default; `dutils theme` can pin it |
| **bat** | `BAT_THEME=ansi` — renders with the terminal's ANSI colours (matches in light *and* dark) |
| **fzf** | `FZF_DEFAULT_OPTS` uses ANSI colour indices, so the picker follows the terminal too |
| **delta** | `syntax-theme = base16-256` — already ANSI-following |
| **neovim** | `ellisonleao/gruvbox.nvim` (default, independent of the terminal's own theme); `current-theme.lua` toggles its light/dark variant from the switch, falling back to `folke/tokyonight.nvim`'s `tokyonight-day`/`-night` if gruvbox isn't available |
| **starship** | left intentionally monochrome/dimmed — palette-neutral, looks right on any background |
| **yazi** | left on its built-in theme (works on any background) |

## Switch it

```bash
dutils theme            # status (default) — show the current mode
dutils theme dark       # pin dark  (ghostty: TokyoNight Night; nvim: gruvbox dark)
dutils theme light      # pin light (ghostty: TokyoNight Day; nvim: gruvbox light)
dutils theme toggle     # flip dark ↔ light
dutils theme auto       # follow the macOS light/dark appearance (default)
```

- **auto** (the default) means ghostty tracks the macOS system appearance — flip
  macOS to light/dark and the terminal + CLI tools follow. Neovim uses the dark
  gruvbox variant in auto mode (same underlying "not literally light → dark"
  check as before this switched from tokyonight — auto mode doesn't currently
  read the live macOS appearance for Neovim's side, just whatever
  `~/.config/dotfiles/theme` last had written to it).
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
