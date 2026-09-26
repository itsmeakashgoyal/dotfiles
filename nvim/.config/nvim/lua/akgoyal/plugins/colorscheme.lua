--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/colorscheme.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Gruvbox: the default colorscheme — coordinates with the rest of the
-- Windows terminal toolchain (Windows Terminal scheme, PSReadLine colors,
-- fzf/tv colors, bat's $BAT_THEME=gruvbox-dark). `lazy = false` (not just
-- `priority`) so it's actually loaded by the time current-theme.lua runs
-- and activates it — current-theme.lua is what calls `vim.cmd.colorscheme`
-- now, not this file, so without `lazy = false` there'd be nothing forcing
-- the plugin to load before that happens.
return {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
            strings = false,
            emphasis = false,
            comments = false,
            folds = false,
            operators = false,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "", -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
    },
}
