# Cheatsheet

Everything you can type or press in this setup. `⌃` Ctrl · `⌥` Option · `⌘` Cmd · `⇧` Shift · **prefix** = tmux `⌃a` · `<leader>` = nvim `Space`.

- [Shell](#shell)
- [Bookmarks](#bookmarks)
- [Python](#python)
- [Git](#git)
- [tmux](#tmux)
- [Neovim](#neovim)
- [iTerm2](#iterm2)
- [dutils & make](#dutils--make)
- [Photos backup](#photos-backup)

## Shell

The command line is in vi mode and every line starts in insert mode. The Powerlevel10k prompt `❯` changes to `❮` in normal mode.

| Keys | Does |
| --- | --- |
| `Esc` / `jk` / `kj` | Switch to normal mode |
| `⌃A` / `⌃E` | Jump to the start / end of the line |
| `⌃K` / `⌃U` | Delete to the end / start of the line |
| `⌃W` | Delete the previous word |
| `⌃L` | Clear the screen |
| `⌥←` / `⌥→` | Move back / forward one word |
| `v` (normal mode) | Edit the current command in `$EDITOR` (nvim) |
| `k` / `j` (normal mode) | Previous / next history entry |
| `/` / `?` (normal mode) | Search history backward / forward |
| `⌃R` | Atuin history search (fuzzy; `Enter` puts the command on the line for editing) |
| `⌃T` | Television smart autocomplete (files, dirs or branches, depending on context) |
| `Tab` after a space | Television autocomplete |
| `Tab` mid-word or on an empty line | Normal zsh completion |

**Abbreviations:** type the trigger, then press `Space` to expand it.

| Type | Becomes |
| --- | --- |
| `cp file.txt _bak` | `cp -a file.txt{,.bak-YYYYmmdd-HHMM}` |
| `echo hi _xrg wc` | `echo hi \| xargs -I {} wc {}` |
| `<cmd> newdir _ind` | `mkdir -p newdir && <cmd>` |
| `_chmo` | Pick a file with fzf and run `chmod +x` on it |

**Listing and viewing files**

| Command | Does |
| --- | --- |
| `l` / `ll` | `eza` long list of all files (`l` adds git status, `ll` puts directories first) |
| `lt` | Tree view, 2 levels deep |
| `cat` / `catn` | `bat` with syntax highlighting / plain |
| `tre` | `tree` including hidden files, skipping `.git` and `node_modules`, paged |
| `file.md` (or `.txt` `.yaml` `.json`) | Typing just a filename opens it in nvim |

**Moving around**

| Command | Does |
| --- | --- |
| `cd <partial>` | zoxide jump by frecency (`cd` is zoxide) |
| `cx <dir>` / `mkcd <dir>` | `cd` into a directory and list it / create a directory and `cd` into it |
| `up 3` / `grt` / `cdf` | Go up 3 directories / to the git repo root / to the front Finder window's folder |
| `tvd` / `fv` | Pick a directory with tv and `cd` into it / pick a file and open it in nvim |

**Global aliases:** these work anywhere in a command, e.g. `ls G foo`.

| Alias | Expands to |
| --- | --- |
| `C` / `L` | `\| pbcopy` / `\| less` |
| `G` | `\| grep -i --color=always` |
| `T` / `S` | `\| tail -n +2` (skip the first line) / strip leading whitespace |
| `W` | View the output in nvim as markdown (`q` quits) |
| `H` / `V` | `--help` / `--version` |
| `NUL` / `R` | `> /dev/null 2>&1` / `2>&1 \| tee output.txt` |

**Utilities**

| Command | Does |
| --- | --- |
| `serve [port]` | Serve the current directory over HTTP (default port 8000) |
| `extract <archive>` / `targz <dir>` | Extract any common archive format / create a `.tar.gz` |
| `fs [path]` / `du` / `df` | Size of a path / disk usage sorted by size / free disk space |
| `diff a b` | Word-level colored diff (`git diff --no-index`) |
| `fk` / `pkill` | Pick a process with tv and kill it (`fk` sends `-9`, `pkill` sends `-15`) |
| `myip` / `ip_info` / `disks` | Public IP / local and public IPs / disk and mount info |
| `update` / `caffeinate1h` | Update macOS, Homebrew and global npm packages / keep the Mac awake for 1 hour |

**Docker**

| Command | Does |
| --- | --- |
| `dps` / `dpa` / `di` | Running containers / all containers / images |
| `dbash <name>` / `dcip <name>` | Open a shell inside a container / show the container's IP address |
| `dstop` / `drm` / `drmf` / `dri` | Stop / remove / stop and remove all containers, remove all images (each asks first) |
| `dcp` / `dip` / `dnp` / `dsp` | Prune containers / images / networks / everything unused |

## Bookmarks

Each bookmark works anywhere a path does, e.g. `cd ~df`, `nvim ~cfg/zsh/.zshrc`. A bookmark only exists if its target directory exists.

| Bookmark | Path |
| --- | --- |
| `~df` | `~/dotfiles` |
| `~cfg` | `~/.config` |
| `~zdot` | `$ZDOTDIR` (`~/.config/zsh`) |
| `~dl` | `~/Downloads` |
| `~dev` | `~/ws` |
| `~ltb` | `~/linuxtoolbox` |

## Python

`python`/`py3` → `python3` (mise, 3.14); `pip` → `pip3`. The venv helpers use uv and default to `.venv`.

| Command | Does |
| --- | --- |
| `mkvenv [dir] [version]` | Create a venv with uv and activate it, e.g. `mkvenv .venv 3.12` |
| `venv [dir]` | Activate an existing venv |
| `rmvenv [dir]` | Deactivate the venv if it's active, then delete it |
| `uv pip install <pkg>` | Install a package into the active venv |
| `cd .` | Re-apply mise after editing `mise.toml` in the current directory |

## Git

**Git aliases** (from `git/.config/git/config`), used as `git <alias>`:

| Command | Does |
| --- | --- |
| `git s` / `git l` / `git d` | `status` / one-line graph of the last 20 commits / diff with stats |
| `git go <branch>` | Switch to a branch, creating it if it doesn't exist |
| `git amend` / `git ca` | Amend the last commit, keeping its message / stage everything and commit (`-av`) |
| `git dm` | Delete branches already merged (keeps main, master and develop) |
| `git fc <text>` / `git fm <text>` | Find commits whose diff adds or removes `<text>` / whose message contains it |
| `git whoami` | Show the identity git uses in this repo |
| `git open` / `git prs` | Open the repo / its PR list in the browser (gh) |
| `git c <url>` / `git sm-init` / `git sm-update` | Clone with submodules / initialize submodules / update them |

**Shell shortcuts:** the `tv` pickers run when you give no argument.

| Command | Does |
| --- | --- |
| `gs` / `glog` | `git status` / pretty graph log |
| `gco [branch]` / `gcr` | Check out a local branch / fetch, then check out a remote branch (picker) |
| `gch` | Check out one of the last 10 branches you were on |
| `gct` / `gpr` | Check out a tag / a GitHub PR (picker) |
| `gbd [branch]` / `delete-branches` | Delete a branch (type `delete` to confirm) / delete branches one at a time in a loop |
| `gcmsg msg` / `gcam msg` | Commit / stage everything and commit |
| `gac "msg"` / `gacs "msg"` | Stage everything, commit and push (`gacs` adds a sign-off) |
| `gstam msg` / `gstab msg` | Stash everything / stash a backup but keep the changes |
| `gundo [n]` / `nah` | Undo the last n commits, keeping the changes / discard all changes to the Trash (asks first) |
| `gc` | ⚠️ `git clean -fxd` (deletes untracked and ignored files) |

## tmux

The prefix is `⌃a`. Press `⌃a ⌃a` to send it to a nested session. Windows and panes are numbered from 1, and the mouse is on.

| Keys | Does |
| --- | --- |
| `prefix r` / `prefix c` | Reload `tmux.conf` / new window in the current directory |
| `prefix \|` / `prefix -` | Split side by side / top and bottom (keeps the current directory) |
| `⌃h` `⌃j` `⌃k` `⌃l` | Move between panes, and between nvim splits too (no prefix) |
| `prefix h/j/k/l` / `prefix H/J/K/L` | Move between panes (repeatable) / resize the pane by 5 |
| `prefix n` / `p` / `Space` | Next / previous / last window (`⌃n` / `⌃p` also work) |
| `prefix N` / `P` / `X` | Move the window right / left / kill a window by number (prompts) |
| `prefix B` / `prefix E` | Move the pane to its own window / bring a pane back in |
| `prefix g` / `prefix o` | Open lazygit / run an app (prompts) in a new window |
| `prefix ⌃e` / `prefix b` | Pick a session with tv in a popup / switch to the last session |
| `prefix d` / `prefix s` / `prefix $` | Detach / session tree / rename the session (tmux defaults) |
| `prefix I` / `prefix U` | Install / update TPM plugins |
| `prefix ⌃s` / `prefix ⌃r` | Save / restore sessions (resurrect; continuum restores them on start) |

**Copy & paste** (everything copied goes to the system clipboard, also over ssh):

| Keys | Does |
| --- | --- |
| Drag with the mouse | Select; copied on release (double / triple click: word / line) |
| `⌥` + drag (iTerm2) | Use the terminal's own selection instead of tmux's, then `⌘C` |
| `prefix [` → `v` (or `⌃v` block) → `y` | Copy with the keyboard (vi keys to move) |
| `⌘V` | Paste the system clipboard, same as outside tmux |
| `prefix ]` | Paste tmux's last copy |

| Shell command | Does |
| --- | --- |
| `ta [name]` | Attach to a session, creating it if needed (default name `misc`) |
| `tn <name>` / `tk <name>` / `td` | New session / kill a session / detach |
| `tl` / `tls` / `tks` | List sessions / switch to one (picker) / kill one (picker) |

## Neovim

The leader key is `Space`. Press `<leader>?` to list the keymaps for the current buffer, or `<leader>pk` to search all keymaps.
Main plugins: lazy.nvim, telescope, snacks, harpoon, oil, mason and native LSP, conform, treesitter, trouble, nvim-dap, neotest, diffview, lazygit (via snacks), yanky, mini.surround and mini.comment, ufo, aerial, which-key, supermaven, gruvbox.

| Keys | Does |
| --- | --- |
| `<leader>sf` / `sg` / `sw` | Find files / live grep / grep the word under the cursor (telescope) |
| `<leader>sb` / `sr` / `sh` / `sc` / `sd` | Buffers / recent files / help / commands / diagnostics |
| `<leader>/` | Fuzzy search in the current buffer |
| `⌃j` / `⌃k`, `⌃q` (in telescope) | Move through results, send them to the quickfix list |
| `<leader>pf` / `pc` / `ps` / `pws` | Snacks: files / nvim config files / grep / grep the word or selection |
| `<leader>pt` / `pT` / `pp` | TODO comments / TODO, FIX and FIXME / projects |
| `-` / `<leader>-` | Oil: open the parent directory / open it in a floating window |
| `<leader>a` / `⌃e` | Harpoon: add the file / open the menu |
| `⌃y` `⌃i` `⌃n` `⌃s` | Harpoon: jump to file 1 / 2 / 3 / 4 |
| `⌃⇧p` / `⌃⇧n` | Harpoon: previous / next file |
| `gd` / `gD` / `gi` / `gt` / `gR` | LSP: definition / declaration / implementation / type / references |
| `K` / `⌃h` (insert mode) | Hover docs / signature help |
| `<leader>rn` / `<leader>vca` | Rename (live preview) / code actions |
| `<leader>ld` / `<leader>D` / `<leader>lx` | Diagnostics for the line / the buffer / toggle diagnostics on and off |
| `<leader>f` / `<leader>cf` / `<leader>rs` | Format with LSP / format with conform (works on a selection) / restart LSP |
| `<leader>xw` / `xd` / `xq` / `xl` / `xt` | Trouble: workspace / document diagnostics, quickfix, location list, todos |
| `<leader>lg` / `<leader>gl` / `<leader>gbr` | lazygit / lazygit log / pick a git branch and switch to it |
| `<leader>gd` / `gD` / `gH` | Diffview: toggle / history of this file / history of the repo |
| `<leader>db` / `dc` / `di` / `do` / `dO` | Debug: breakpoint / continue / step into / over / out |
| `<leader>dB` / `du` / `de` / `dr` / `dt` | Debug: conditional breakpoint / UI / evaluate / restart / stop |
| `<leader>Tt` / `Tf` / `Td` / `Ts` / `To` | Tests: nearest / file / debug nearest / summary / output |
| `<leader>Re` / `Rv` / `Ri` / `Rs` | Refactor: extract function / extract variable / inline variable / pick from a menu |
| `<leader>sv` / `sh` / `se` / `sx` / `sm` | Splits: vertical / horizontal / make equal / close / maximize |
| `<leader>to` / `tx` / `tn` / `tp` | Tabs: new / close / next / previous |
| `<leader>bd` / `<leader>rN` / `<leader>fp` / `<leader>x` | Close the buffer / rename the file / copy the file path / make the file executable |
| `<leader>o` / `[s` / `]s` | Code outline (aerial) / previous / next symbol |
| `<leader>u` / `<leader>yh` / `[y` `]y` | Undo tree / yank history / cycle through the yank history after a paste |
| `<leader>s` (then wait) | Replace the word under the cursor everywhere in the file |
| `<leader>p` (visual) / `<leader>d` / `<leader>Y` | Paste without overwriting the register / delete without copying / copy the line to the system clipboard |
| `J` / `K` (visual) | Move the selected lines down / up |
| `sa` / `sd` / `sr` | Add / delete / replace surrounding characters (mini.surround) |
| `gcc` / `gc` | Comment out the line / a selection or motion |
| `⌃a` / `⌃x` | Increment / decrement numbers, dates and booleans (dial) |
| `⌃Space` | Grow the treesitter selection (or trigger completion in insert mode) |
| `zR` / `zM` / `zK` | Open all folds / close all folds / peek inside a fold |
| `⌃l` / `⌃]` / `⌃→` (insert mode) | Supermaven: accept / clear / accept one word |
| `<leader>vs` / `<leader>ue` / `<leader>ct` / `<leader>th` | Pick a Python venv / toggle hiding `.env` values / toggle the context bar / pick a colorscheme |
| `⌃c` | Leave insert mode in insert mode, clear search highlighting in normal mode |

## iTerm2

The left `⌥` acts as Meta (sends `Esc+`), and the right `⌥` types special characters as usual.

| Keys | Does |
| --- | --- |
| `⌥Space` | Show or hide the drop-down hotkey window (Gruvbox Hotkey profile) |
| `⌥←` / `⌥→` | Move back / forward one word |
| `⌘←` / `⌘→` | Go to the start / end of the line |
| `⌥⌫` | Delete the previous word |
| `⌘⌫` | Delete to the start of the line |

## dutils & make

`dutils` is on your `PATH` via the `bin` package. Use `dutils <cmd> --help` for details, or `dutils menu` to pick a command.

| Command | Does |
| --- | --- |
| `dutils menu` / `dutils init` | Interactive command picker / first-run wizard (git identities and SSH keys, secrets, theme) |
| `dutils sync` / `dutils update` | Pull the latest dotfiles, re-stow and update / update Homebrew, Nix, mise, zinit and Neovim |
| `dutils health` / `check` / `diagnose` | Quick check / full check with a score / every diagnostic |
| `dutils packages` / `dutils manifest generate` | Compare installed tools against `packages.toml` / regenerate the package lists |
| `dutils edit <pkg>` / `dutils new <pkg>` | Open a package's config / create a new Stow package |
| `dutils git-setup` | Set up git identities and SSH keys (`status`, `add`, `test`) |
| `dutils secrets init/add/decrypt/edit/list` | Manage age-encrypted secrets |
| `dutils theme [dark\|light\|auto\|apply]` | Switch the terminal theme (Gruvbox) |
| `dutils bench` / `dutils bench --real` | Shell startup time / real per-prompt lag (zsh-bench) |
| `dutils profile` / `dutils zcompile` | Profile zsh startup / precompile zsh config |
| `dutils vulns` / `dutils cleanup [component]` | Scan Homebrew packages for CVEs / remove dotfiles, Homebrew, nvim or tmux config |
| `dutils ytd [-a] [-q 1080] <url>` | Download a YouTube video or playlist (`-a` audio only, `-n` dry run) |
| `dutils organize-media <dir> [--dry-run]` | Sort a flat photo/video folder into `YYYY/MM` folders (`--dest D --copy` to copy elsewhere) |
| `dutils diff` / `sysinfo` / `list-functions` | Live diff of two picked files / system info / list custom zsh functions |

| Make target | Does |
| --- | --- |
| `make install` (`dry=1`) | Full bootstrap (`dry=1` previews it) |
| `make run` / `make update` / `make delete` | Stow / re-stow / unstow every package |
| `make stow pkg=x` / `make unstow pkg=x` / `make list` | Stow / unstow one package / list packages |
| `make health` / `check` / `menu` / `manifest` / `bench-real` | Same as the matching `dutils` commands |
| `make iterm` / `make sublime` / `make apps` | Set up iTerm2 / Sublime Text / both |
| `make macos-defaults` (`undo=1`, `dry=1`) | Apply the curated macOS defaults (`undo=1` reverts, `dry=1` previews) |
| `make nix-switch` / `make uninstall` | Apply `home.nix` (Linux) / uninstall gracefully |

## Photos backup

`osxphotos` exports from the Photos library, including edits, Live Photo videos and RAW files. It never modifies the library. Run it with `--dry-run` first, then with `--update` (re-running only exports new or changed items):

```bash
osxphotos export ~/Desktop/PhotosBackup \
  --library "~/Pictures/Photos Library.photoslibrary" \
  --directory "{created.year}/{created.month:02d}" \
  --download-missing --touch-file --update   # first run: --dry-run instead of --update
```

`--download-missing` downloads originals stored only in iCloud, so check you have enough free disk space. To upgrade osxphotos, run `pipx upgrade osxphotos`. To sort a flat export folder that has no Photos library, use `dutils organize-media`.
