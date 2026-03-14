# Screenshots & Demo Recordings

This guide explains how to create terminal screenshots and animated GIF demos for the README.

---

## Recommended Tool: `vhs`

[VHS](https://github.com/charmbracelet/vhs) by Charm lets you write terminal recordings as code (`.tape` files) and export them as GIFs or WebP animations. It produces consistent, reproducible demos.

### Install

```bash
brew install vhs
```

VHS requires a headless terminal renderer. Install it with:

```bash
brew install ttyd
```

---

## Recording Your Setup

### 1. Zsh Prompt & Navigation Demo

Create `docs/tapes/prompt.tape`:

```tape
Output docs/img/prompt.gif

Set Shell "zsh"
Set FontSize 16
Set Width 1200
Set Height 600
Set Theme "Catppuccin Mocha"
Set TypingSpeed 80ms
Set Padding 20

Type "# Welcome to my dotfiles setup"
Enter
Sleep 1s

Type "ls"
Enter
Sleep 1s

Type "l"
Enter
Sleep 1.5s

Type "cd ~/dotfiles"
Enter
Sleep 500ms

Type "make health"
Enter
Sleep 3s
```

```bash
vhs docs/tapes/prompt.tape
```

### 2. Neovim with LSP Demo

```tape
Output docs/img/neovim.gif

Set Shell "zsh"
Set FontSize 15
Set Width 1400
Set Height 800
Set Theme "Catppuccin Mocha"
Set TypingSpeed 60ms
Set Padding 20

Type "nvim ~/dotfiles/zsh/.config/zsh/conf.d/aliases.zsh"
Enter
Sleep 3s

Type "/eza"
Enter
Sleep 1s

Type "zz"
Sleep 1s

Type ":q"
Enter
```

### 3. Git Workflow with Delta

```tape
Output docs/img/git-delta.gif

Set Shell "zsh"
Set FontSize 15
Set Width 1200
Set Height 700
Set Padding 20

Type "cd ~/dotfiles"
Enter
Sleep 500ms

Type "git diff HEAD~1"
Enter
Sleep 3s
```

### 4. FZF in Action

```tape
Output docs/img/fzf.gif

Set Shell "zsh"
Set FontSize 15
Set Width 1200
Set Height 500
Set Padding 20

# Show ctrl-r history search
Type "# Press Ctrl+R for fuzzy history search"
Enter
Sleep 1s
Ctrl+r
Sleep 500ms
Type "make"
Sleep 2s
Escape
```

---

## Static Screenshots

For static screenshots, use iTerm2 or Ghostty with a high-DPI display:

1. Set your terminal to a clean state (no pending prompts)
2. Set font size 15–16px, window width ~140 columns
3. Use **Catppuccin Mocha** or **Tokyo Night** for a visually appealing dark theme
4. Take screenshot with `Cmd+Shift+4` (macOS), crop to terminal window

---

## Adding to README

Once you have images in `docs/img/`, add them to the README after the banner:

```markdown
## Preview

| Zsh Prompt | Neovim + LSP |
|---|---|
| ![Prompt](docs/img/prompt.gif) | ![Neovim](docs/img/neovim.gif) |

| Git Delta | FZF Search |
|---|---|
| ![Delta](docs/img/git-delta.gif) | ![FZF](docs/img/fzf.gif) |
```

---

## Directory Structure

```
docs/
├── img/           ← Generated GIFs and screenshots
├── tapes/         ← VHS tape scripts
├── ARCHITECTURE.md
└── SCREENSHOTS.md
```

Create the directories:

```bash
mkdir -p docs/img docs/tapes
```

Add `docs/img/*.gif` to git (GIFs are usually < 2MB with VHS):

```bash
git add docs/img/
git commit -m "docs: add terminal demo recordings"
```
