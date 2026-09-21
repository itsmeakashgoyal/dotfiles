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
| **UI** | `A File Icon`, `SideBarEnhancements`, Adaptive theme + a vendored **Tokyo Night** color scheme (matches the rest of the toolchain) |
| **Build/run** | `C++ Single File` (clang++ compile+run, Windows `.exe` variant) and `Python3` build systems |

### Keymap (`Default.sublime-keymap`, all platforms)

| Keys | Action |
| --- | --- |
| `ctrl+alt+t` | Toggle the Terminus terminal panel |
| `ctrl+alt+f` | LSP format document |
| `f2` | LSP rename symbol |
| `ctrl+alt+r` | LSP find references |

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

- The Tokyo Night color scheme is **vendored** (`settings/sublime/Tokyo Night.sublime-color-scheme`)
  rather than a Package Control theme, so it renders identically on every OS with
  no package to resolve.
- `Vintage` (vi mode) stays disabled, matching the current setup.
- Package list lives in `Package Control.sublime-settings`; add/remove there.
