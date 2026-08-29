--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/oil.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Oil: file explorer that edits directories as regular buffers, replaces netrw.
return {
    "stevearc/oil.nvim",
    -- enabled = false,
    -- eager on purpose: oil replaces netrw as the directory-buffer handler
    -- (default_file_explorer = true below), which needs to be registered
    -- before netrw's own autocmds would otherwise fire.
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        require("oil").setup({
            default_file_explorer = true, -- start up nvim with oil instead of netrw
            columns = {},
            keymaps = {
                ["<C-h>"] = false,
                ["<C-c>"] = false, -- prevent from closing Oil as <C-c> is esc key
                ["<M-h>"] = "actions.select_split",
                ["q"] = "actions.close",
            },
            delete_to_trash = true,
            view_options = {
                show_hidden = true,
            },
            skip_confirm_for_simple_edits = true,
        })

        -- opens parent dir over current active window
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        -- open parent dir in float window
        vim.keymap.set("n", "<leader>-", require("oil").toggle_float)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "oil", -- Adjust if Oil uses a specific file type identifier
            callback = function()
                vim.opt_local.cursorline = true
            end,
        })
    end,
}
