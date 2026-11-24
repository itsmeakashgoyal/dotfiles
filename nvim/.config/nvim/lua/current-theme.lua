--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/current-theme.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Gruvbox, light or dark to match the terminal (see docs/THEME.md).
--   1. $DOTFILES_THEME — exported by the shell, already resolved to dark|light
--   2. ~/.config/dotfiles/theme (written by `dutils theme`) — dark|light|auto;
--      "auto" leaves 'background' to Neovim's own terminal detection (OSC 11)
--   3. otherwise dark
-- gruvbox.nvim is one colorscheme that respects 'background', so light/dark is
-- just that option. Falls back to the built-in habamax if gruvbox is missing.
local mode = vim.env.DOTFILES_THEME
if mode ~= "dark" and mode ~= "light" then
    local f = io.open(vim.fn.expand("~/.config/dotfiles/theme"), "r")
    if f then
        mode = (f:read("l") or ""):gsub("%s+", "")
        f:close()
    end
end

if mode == "light" or mode == "dark" then
    vim.o.background = mode
elseif mode ~= "auto" then
    vim.o.background = "dark"
end

if not pcall(vim.cmd.colorscheme, "gruvbox") then
    vim.cmd.colorscheme("habamax")
end
