--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/vim-maximizer.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Vim-maximizer: toggles a split window between maximized and restored size.
return {
    "szw/vim-maximizer",
    keys = {
        { "<leader>sm", "<cmd>MaximizerToggle<CR>", desc = "Maximize/minimize a split" },
    },
}
