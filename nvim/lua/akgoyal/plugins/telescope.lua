return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
        "andrew-george/telescope-themes",
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")

        telescope.load_extension("fzf")
        telescope.load_extension("themes")

        telescope.setup({
            defaults = {
                path_display = { "smart" },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                    },
                },
            },
            extensions = {
                themes = {
                    enable_previewer = true,
                    enable_live_preview = true,
                    persist = {
                        enabled = true,
                        path = vim.fn.stdpath("config") .. "/lua/colorscheme.lua",
                    },
                },
            },
        })

        -- Keymaps
        vim.keymap.set("n", "<leader>pr", "<cmd>Telescope oldfiles<CR>", { desc = "Fuzzy find recent files" })
        vim.keymap.set("n", "<leader>pWs", function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end, { desc = "Find Connected Words under cursor" })

        vim.keymap.set(
            "n",
            "<leader>ths",
            "<cmd>Telescope themes<CR>",
            { noremap = true, silent = true, desc = "Theme Switcher" }
        )

        vim.keymap.set("n", "<leader>/", function()
            -- You can pass additional configuration to telescope to change theme, layout, etc.
            require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = true,
            }))
        end, {
            desc = "[/] Fuzzily search in current buffer]",
        })

        vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, {
            desc = "[S]earch [F]iles",
        })
        -- vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
        vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, {
            desc = "[S]earch current [W]ord",
        })
        vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, {
            desc = "[S]earch by [G]rep",
        })
        vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, {
            desc = "[S]earch [D]iagnostics",
        })
        vim.keymap.set("n", "<leader>sb", require("telescope.builtin").buffers, {
            desc = "[ ] Find existing buffers",
        })
        vim.keymap.set("n", "<leader>sS", require("telescope.builtin").git_status, {
            desc = "",
        })
        vim.keymap.set("n", "<leader>sm", ":Telescope harpoon marks<CR>", {
            desc = "Harpoon [M]arks",
        })
        vim.keymap.set(
            "n",
            "<Leader>sr",
            "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>",
            silent
        )
        vim.keymap.set(
            "n",
            "<Leader>sR",
            "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>",
            silent
        )
        vim.keymap.set("n", "<Leader>sn", "<CMD>lua require('telescope').extensions.notify.notify()<CR>", silent)

        vim.api.nvim_set_keymap("n", "st", ":TodoTelescope<CR>", {
            noremap = true,
        })
        vim.api.nvim_set_keymap("n", "<Leader><tab>", "<Cmd>lua require('telescope.builtin').commands()<CR>", {
            noremap = false,
        })
    end,
}
