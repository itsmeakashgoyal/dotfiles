--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/current-theme.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Active colorscheme, kept separate so switching themes is a one-line change.
-- Honors `dutils theme`, which writes ~/.config/dotfiles/theme = dark|light|auto:
-- "light" → gruvbox with background=light, anything else → background=dark.
-- gruvbox is one colorscheme name that respects `vim.o.background` (unlike
-- tokyonight's separate tokyonight-day/tokyonight-night names), so the light/
-- dark switch is a background setting here, not a different colorscheme name.
-- Falls back to tokyonight if gruvbox isn't available.
local mode = "dark"
local f = io.open(vim.fn.expand("~/.config/dotfiles/theme"), "r")
if f then
    local line = (f:read("l") or ""):gsub("%s+", "")
    f:close()
    if line == "light" then
        mode = "light"
    end
end

vim.o.background = mode
if not pcall(vim.cmd.colorscheme, "gruvbox") then
    vim.cmd.colorscheme(mode == "light" and "tokyonight-day" or "tokyonight-night")
end
