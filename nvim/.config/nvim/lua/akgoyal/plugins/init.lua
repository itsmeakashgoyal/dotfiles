--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/init.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Foundational plugins: plenary.nvim (shared Lua utility library) and vim-tmux-navigator (tmux/vim split navigation).
return {
    { "nvim-lua/plenary.nvim", lazy = true }, -- lua functions that many plugins use; loaded transitively via dependents

    {
        "christoomey/vim-tmux-navigator", -- tmux & split window nav
        -- plugin's own default mappings; no custom config here to piggyback
        -- a `keys` trigger on, so list them directly (lazy.nvim replays the
        -- keypress after load, letting the plugin's own mapping take over)
        keys = { "<C-h>", "<C-j>", "<C-k>", "<C-l>", "<C-\\>" },
    },
}
