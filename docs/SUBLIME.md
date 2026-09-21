# Sublime Text (cross-platform IDE)

Sublime Text set up as a genuine day-to-day IDE that behaves the same on
**macOS, Linux, and Windows**. Settings live in `settings/sublime/` and are
**symlinked** into Sublime's per-OS User dir, so editing the repo updates the
editor live.

## What's configured

| Area | Detail |
| --- | --- |
| **LSP** | `LSP` + `LSP-pyright` (Python), `LSP-ruff` (Python lint/format), `LSP-json`, `LSP-yaml`; **clangd** for C/C++ configured in `LSP.sublime-settings` |
| **Editing** | `EditorConfig`, `BracketHighlighter`, `DocBlockr`, `AutoFileName`, format-on-save + organize-imports (via LSP) |
| **Terminal** | `Terminus` integrated terminal — toggle with `ctrl+alt+t` |
| **Git** | `GitGutter` (inline diff in the gutter) |
| **UI** | `A File Icon`, `SideBarEnhancements`, built-in Adaptive theme + a **vendored gruvbox** color scheme |
| **Build/run** | `C++ Single File` (clang++ compile+run, Windows `.exe` variant) and `Python3` build systems |
| **Search** | Inline highlight of all matches + a Notepad++-style results list (see below) |

### Keymap (`Default.sublime-keymap`, all platforms)

| Keys | Action |
| --- | --- |
| `ctrl+alt+t` | Toggle the Terminus terminal panel |
| `ctrl+alt+f` | LSP format document |
| `f2` | LSP rename symbol |
| `ctrl+alt+r` | LSP find references |
| `ctrl+alt+shift+f` | Find All in the **current file** → results list (Notepad++ style) |

## Find & "Find All" (Notepad++ equivalent)

Sublime splits this across two features:

- **`Ctrl/Cmd+F` — Find.** Highlights **every** match inline in the file
  (colour highlighting, like Notepad++'s Mark). The panel's **Find All** button
  puts a cursor on each match so you can edit them all at once.
- **`Ctrl/Cmd+Shift+F` — Find in Files.** This is the Notepad++ "Find All"
  results panel: a **Find Results** view listing every match with its line
  number, grouped by file, the matched text colour-highlighted; `Enter` or
  double-click jumps to a match, and `F4` / `Shift+F4` step through them. Set
  **Where** to `<current file>` to search only the current document, or a
  folder/`<open files>` for a project-wide search.

The extra keybinding **`ctrl+alt+shift+f`** opens Find in Files already scoped to
the current file — press `Enter` and you get the results list for just this file,
matching Notepad++'s "Find All in Current Document".

**Want it docked at the bottom** like Notepad++? The Find Results open as a
normal tab; drag that tab into a bottom group (View → Layout → *Rows: 2*, or
`Ctrl/Cmd+Alt+2`) and Sublime keeps future results there. `find_selected_text`
is on, so the word under the cursor pre-fills the search.

## Prerequisites (language servers)

Package Control auto-installs the listed packages on first launch. The servers
they drive need their tools on `PATH`:

- **C/C++** — `clangd` (macOS: Xcode CLT or `brew install llvm`; Linux: `apt install clangd`; Windows: `scoop install llvm`).
- **Python** — `LSP-pyright` needs **Node.js** (you already manage Node via mise); `LSP-ruff` bundles/downloads `ruff`.
- `LSP-json` / `LSP-yaml` are self-contained.

## Deploying it

- **macOS / Linux** — `make sublime` (runs `scripts/setup/sublime.sh`): symlinks
  every file in `settings/sublime/` into Sublime's User dir and installs Package
  Control. Non-interactive. Per-OS dir:
  - macOS: `~/Library/Application Support/Sublime Text/Packages/User`
  - Linux: `~/.config/sublime-text/Packages/User`
- **Windows** — handled by `scripts/setup/windows.ps1` (the sublime entries in
  `$SYMLINK_MAP` + `Install-SublimePackageControl`); User dir is
  `%APPDATA%\Sublime Text\Packages\User`.

Because the files are symlinked, `git pull` + editing the repo updates Sublime
directly — no re-copy step.

## Notes

- Theme: **gruvbox** colors via a **vendored** color scheme
  (`settings/sublime/Gruvbox Dark.sublime-color-scheme`) + the built-in Adaptive
  UI theme — no Package Control theme to resolve, so it works offline / on
  locked-down networks with no "unable to find colour scheme" errors. Kept
  separate from the Tokyo Night palette the terminal toolchain uses.
- `Vintage` (vi mode) stays disabled, matching the current setup.
- Package list lives in `Package Control.sublime-settings`; add/remove there.
- **Note on churn:** `Preferences.sublime-settings` and
  `Package Control.sublime-settings` are the two files Sublime/Package Control
  rewrite at runtime (`ignored_packages`, `in_process_packages`) — and since
  they're symlinked, those writes flow into the repo. This mostly happens once
  during first-launch package installation and settles afterward; if you toggle
  packages from the UI later, revert with `git checkout` or keep the change.
