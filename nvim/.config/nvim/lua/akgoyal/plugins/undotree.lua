--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/undotree.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Undotree: visualizes and navigates the buffer's undo history as a tree.
return {
    "mbbill/undotree",
    keys = {
        { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle undo tree" },
    },
}
