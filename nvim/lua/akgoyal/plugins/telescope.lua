return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")

        telescope.load_extension("fzf")

        telescope.setup({
            defaults = {
                path_display = { "smart" },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                    },
                },
            },
        })

        -- Keymaps
        vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search Files" })
        vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search by Grep" })
        vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search current Word" })
        vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Search Buffers" })
        vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
        vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search Diagnostics" })
        vim.keymap.set("n", "<leader>sr", builtin.oldfiles, { desc = "Search Recent files" })
        vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "Search Commands" })
        
        -- Search in current buffer
        vim.keymap.set("n", "<leader>/", function()
            builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, { desc = "Fuzzy search in current buffer" })
    end,
}
