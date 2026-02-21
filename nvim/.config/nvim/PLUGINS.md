# Neovim Configuration - Multi-Language Development

This is a simplified Neovim configuration focused on C/C++, Python, Bash/Shell, and Lua development.

## Core Plugins

### Language Support
- **LSP (mason.nvim, nvim-lspconfig)** - Language Server Protocol support
  
**C/C++:**
  - `clangd` - Language server with diagnostics, completion, and formatting
  - `clang-format` - Code formatter
  - `codelldb` - Debugger

**Python:**
  - `pyright` - Language server with type checking and IntelliSense
  - `black` - Code formatter
  - `isort` - Import sorter
  - `pylint` - Linter

**Bash/Shell:**
  - `bashls` - Language server for sh, bash, and zsh
  - `shfmt` - Shell script formatter
  - `shellcheck` - Shell script linter

**Lua:**
  - `lua_ls` - Language server (configured for Neovim development)
  - `stylua` - Code formatter

### Completion & Snippets
- **nvim-cmp** - Autocompletion engine
  - LSP-based completion
  - Buffer and path completion
  - Snippet support via LuaSnip
  - Smart tab/shift-tab navigation

### Syntax & Navigation
- **nvim-treesitter** - Advanced syntax highlighting and code understanding
  - C/C++ support
  - Python support
  - Bash/Shell support
  - Lua support
  - CMake, Makefile support
  - Git, Markdown, and config files (JSON, YAML, TOML)

### File Navigation
- **telescope.nvim** - Fuzzy finder for files, text, and more
  - `<leader>sf` - Find files
  - `<leader>sg` - Live grep search
  - `<leader>sw` - Search word under cursor
  - `<leader>sb` - Search buffers
  - `<leader>sd` - Search diagnostics
  - `<leader>/` - Search in current buffer

- **oil.nvim** - File explorer (edit filesystem like a buffer)

### UI & Appearance
- **gruvbox.nvim** - Colorscheme
- **lualine.nvim** - Status line
- **which-key.nvim** - Keybinding hints
- **noice.nvim** - Enhanced UI for messages, cmdline, and popupmenu
- **incline.nvim** - Floating statuslines for each window
- **showkeys.nvim** - Show keystrokes on screen (useful for screencasts)
- **snacks.nvim** - Collection of small QoL improvements (dashboard, notifier, etc.)

### Editing Utilities
- **auto-pairs** - Automatic bracket pairing
- **undotree** - Visualize undo history
- **trouble.nvim** - Pretty diagnostics list
- **vim-maximizer** - Toggle window maximization
- **vim-tmux-navigator** - Seamless tmux/vim navigation

## Key Bindings

### Leader Key
Leader key is set to `<Space>`

### LSP Keybindings (when LSP is active)
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gt` - Go to type definition
- `gr` - Show references
- `K` - Show hover documentation
- `<leader>rn` - Rename symbol
- `<leader>vca` - Code actions
- `<leader>d` - Show line diagnostics
- `<leader>D` - Show buffer diagnostics
- `<leader>f` - Format code
- `<leader>rs` - Restart LSP

### File Navigation
- `<leader>sf` - Search files
- `<leader>sg` - Search by grep
- `<leader>sw` - Search word
- `<leader>sb` - Search buffers
- `<leader>sh` - Search help
- `<leader>sr` - Search recent files
- `<leader>/` - Search in current buffer

### Window Management
- `<leader>sv` - Split vertically
- `<leader>sh` - Split horizontally
- `<leader>se` - Make splits equal
- `<leader>sx` - Close split
- `<C-h/j/k/l>` - Navigate between splits

### Tab Management
- `<leader>to` - Open new tab
- `<leader>tx` - Close tab
- `<leader>tn` - Next tab
- `<leader>tp` - Previous tab

### Editing
- `J/K` (visual mode) - Move selected lines up/down
- `<leader>p` - Paste without yanking
- `<leader>Y` - Yank to system clipboard
- `<leader>d` - Delete without yanking

## Configuration Structure

```
nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── akgoyal/
│   │   ├── core/
│   │   │   ├── init.lua       # Core module loader
│   │   │   ├── options.lua    # Vim options
│   │   │   └── keymaps.lua    # General keymaps
│   │   ├── lazy.lua           # Plugin manager setup
│   │   └── plugins/           # Plugin configurations
│   │       ├── lsp/
│   │       │   ├── mason.lua  # LSP server installer
│   │       │   └── lspconfig.lua # LSP configuration
│   │       ├── colorscheme.lua
│   │       ├── nvim-cmp.lua
│   │       ├── telescope.lua
│   │       ├── treesitter.lua
│   │       └── ...
│   └── current-theme.lua      # Active colorscheme
└── after/
    └── ftplugin/             # Filetype-specific settings
        ├── c.vim
        ├── cpp.vim
        └── ...
```

## Getting Started

1. **Install dependencies**:
   ```bash
   # macOS
   brew install neovim ripgrep fd
   
   # Ubuntu/Debian
   sudo apt install neovim ripgrep fd-find
   ```

2. **First launch**:
   - Open Neovim: `nvim`
   - Plugins will auto-install via lazy.nvim
   - LSP servers will auto-install via Mason

3. **C/C++ project setup**:
   - For best LSP experience, use `compile_commands.json`
   - CMake: `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`
   - Or use Bear: `bear -- make`

4. **Python project setup**:
   - Pyright will automatically detect virtual environments
   - For best results, create a `pyrightconfig.json` or use `pyproject.toml`
   - Recommended: Use virtual environments (`python -m venv .venv`)

5. **Shell script setup**:
   - Bashls supports sh, bash, and zsh files
   - Shellcheck provides additional linting
   - Add shebang (`#!/bin/bash`) to scripts for proper detection

6. **Lua development**:
   - Lua LSP is pre-configured for Neovim plugin development
   - Automatically recognizes `vim` global
   - Use stylua for consistent formatting
