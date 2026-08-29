--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/which-key.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Which-key: popup showing available keybindings and leader-key groups as you type.
return {
	--I got annoyed so I just stopped using it for a bit
	"folke/which-key.nvim",
    enabled = true,
	event = "VeryLazy",
	init = function()
	    vim.o.timeout = true
	    vim.o.timeoutlen = 500
	end,
	opts = {},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)
		wk.add({
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "code" },
			{ "<leader>C", group = "compiler" },
			{ "<leader>d", group = "debug" },
			{ "<leader>g", group = "git" },
			{ "<leader>l", group = "lsp" },
			{ "<leader>o", group = "outline" },
			{ "<leader>p", group = "picker" },
			{ "<leader>r", group = "rename/restart" },
			{ "<leader>R", group = "refactoring" },
			{ "<leader>s", group = "search/split" },
			{ "<leader>t", group = "tabs" },
			{ "<leader>T", group = "testing" },
			{ "<leader>u", group = "ui toggles" },
			{ "<leader>v", group = "venv/view" },
			{ "<leader>x", group = "trouble" },
			{ "<leader>y", group = "yank" },
		})
	end,
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}