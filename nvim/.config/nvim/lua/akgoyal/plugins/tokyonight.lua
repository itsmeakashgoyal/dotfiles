--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/tokyonight.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Tokyo Night: kept installed as current-theme.lua's fallback, in case
-- gruvbox.nvim (the default — see colorscheme.lua) ever fails to load. Also
-- still what macOS/Linux's ghostty + `dutils theme` coordinate the terminal
-- (bat/fzf/delta) around — this doesn't touch that, only the editor's
-- default colorscheme itself.
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
