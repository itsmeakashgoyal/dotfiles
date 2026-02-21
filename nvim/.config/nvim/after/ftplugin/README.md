# Ftplugin (Filetype Plugin) Directory

## What is ftplugin?

The `after/ftplugin/` directory contains **filetype-specific settings** that are automatically applied when you open files of a particular type. This is a core Neovim/Vim feature that keeps your configuration organized and maintainable.

Files in the `after/` directory are loaded **after** the default ftplugin files, allowing you to override or extend default behavior.

## How It Works

When you open a file, Neovim:
1. Detects the filetype (e.g., `python`, `cpp`, `sh`)
2. Loads the corresponding ftplugin file (e.g., `python.lua`, `cpp.lua`, `sh.lua`)
3. Applies all settings and keymaps **only for that buffer**

This means:
- Settings are **buffer-local** (don't affect other file types)
- Keymaps are **buffer-local** (only work in files of that type)
- No conflicts between different file types

## Current Ftplugin Files

### C/C++ Development

#### `c.lua` - C Language
- **Indentation**: 4 spaces (K&R style)
- **Text width**: 100 characters
- **Compiler**: gcc or clang
- **Keymaps**:
  - `<F9>` - Compile and run (with -std=c11 -Wall -Wextra -O2)
  - `<F8>` - Compile only (using makeprg)

#### `cpp.lua` - C++ Language
- **Indentation**: 4 spaces
- **Text width**: 100 characters
- **Compiler**: g++ or clang++
- **Keymaps**:
  - `<F9>` - Compile and run (with -std=c++17 -Wall -Wextra -O2)
  - `<F8>` - Compile only (using makeprg)
  - `<leader>h` - Switch between header (.h/.hpp) and source (.cpp/.cc) files

### Python Development

#### `python.lua` - Python
- **Indentation**: 4 spaces (PEP 8 compliant)
- **Text width**: 88 characters (Black formatter default)
- **Color column**: Line at 88 characters
- **Keymaps**:
  - `<F9>` - Run Python script in terminal
  - `<F8>` - Run in interactive REPL (prefers ipython if available)
  - `<leader>r` - Quick run and show output in notification

### Shell Development

#### `sh.lua` - Shell Scripts (sh/bash)
- **Indentation**: 2 spaces
- **Text width**: 100 characters
- **Keymaps**:
  - `<F9>` - Make executable and run with bash
  - `<F8>` - Run shellcheck linter (if installed)
  - `<leader>x` - Make script executable (chmod +x)

#### `bash.lua` - Bash Scripts
- **Indentation**: 2 spaces
- **Text width**: 100 characters
- **Keymaps**:
  - `<F9>` - Make executable and run with bash
  - `<F8>` - Run shellcheck linter
  - `<leader>x` - Make script executable

#### `zsh.lua` - Zsh Scripts
- **Indentation**: 2 spaces
- **Text width**: 100 characters
- **Keymaps**:
  - `<F9>` - Make executable and run with zsh
  - `<F8>` - Run shellcheck linter
  - `<leader>x` - Make script executable
  - `<leader>s` - Source the zsh file

## Adding New Ftplugins

To add settings for a new filetype:

1. Create a file named `<filetype>.lua` or `<filetype>.vim` in this directory
2. Add your buffer-local settings using:
   ```lua
   local set = vim.opt_local
   set.tabstop = 4
   set.commentstring = "// %s"
   ```
3. Add buffer-local keymaps using:
   ```lua
   vim.keymap.set("n", "<F9>", function()
       -- Your code here
   end, { buffer = true, silent = true, desc = "Description" })
   ```

## Best Practices

1. **Use buffer-local settings**: Always use `vim.opt_local` instead of `vim.opt`
2. **Use buffer-local keymaps**: Always include `{ buffer = true }` in keymap options
3. **Keep it language-specific**: Only include settings relevant to that filetype
4. **Document keymaps**: Add `desc` to keymaps for which-key integration
5. **Use Lua over Vimscript**: Lua is faster and more maintainable

## Why This Matters

Without ftplugin, you would need to:
- Use autocmds for every filetype-specific setting
- Have a massive, hard-to-maintain config file
- Risk conflicts between different file types
- Manually manage buffer-local settings

With ftplugin, your config is:
- ✅ **Organized**: Each language has its own file
- ✅ **Maintainable**: Easy to find and update settings
- ✅ **Automatic**: Settings apply automatically
- ✅ **Isolated**: No conflicts between file types
- ✅ **Portable**: Easy to share and version control

## Tools and Dependencies

Some features require external tools:

- **C/C++ compilation**: gcc, clang, g++, clang++
- **Python REPL**: ipython (optional, falls back to python3)
- **Shell linting**: shellcheck (highly recommended)

Install shellcheck for better shell script development:
```bash
# macOS
brew install shellcheck

# Linux
apt install shellcheck  # Debian/Ubuntu
dnf install ShellCheck  # Fedora
```

## Testing Your Ftplugin Files

1. Open a file of the target type (e.g., `test.py`)
2. Check if settings are applied: `:set tabstop?` `:set textwidth?`
3. Test keymaps: Try `<F9>`, `<F8>`, etc.
4. Check for errors: `:messages`

## Migration Notes

- ✅ Migrated `cpp.vim` → `cpp.lua` (modernized with Lua)
- ✅ Enhanced `python.lua` with more features
- ✅ Created new `c.lua` for C development
- ✅ Created `sh.lua`, `bash.lua`, `zsh.lua` for shell scripting

