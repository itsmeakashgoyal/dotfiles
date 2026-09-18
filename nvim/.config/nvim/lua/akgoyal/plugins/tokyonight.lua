--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/tokyonight.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Tokyo Night: the palette the whole toolchain coordinates on (terminal, bat,
-- fzf, delta). Provides the tokyonight-night / tokyonight-day colorschemes that
-- current-theme.lua selects based on `dutils theme`. gruvbox is kept installed
-- as a fallback.
return {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        style = "night", -- default dark variant: night/storm/moon
        light_style = "day",
        terminal_colors = true,
    },
}
