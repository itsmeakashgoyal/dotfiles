--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/current-theme.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Active colorscheme, kept separate so switching themes is a one-line change.
-- Honors `dutils theme`, which writes ~/.config/dotfiles/theme = dark|light|auto:
-- "light" → tokyonight-day, anything else → tokyonight-night. Falls back to
-- gruvbox if tokyonight isn't available.
local mode = "dark"
local f = io.open(vim.fn.expand("~/.config/dotfiles/theme"), "r")
if f then
    local line = (f:read("l") or ""):gsub("%s+", "")
    f:close()
    if line == "light" then
        mode = "light"
    end
end

local scheme = mode == "light" and "tokyonight-day" or "tokyonight-night"
if not pcall(vim.cmd.colorscheme, scheme) then
    vim.cmd.colorscheme("gruvbox")
end
