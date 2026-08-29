return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	-- bare-string triggers, same idea as telescope.lua. <C-i> is deliberately
	-- omitted: it's terminal-identical to <Tab> (same byte), so including it
	-- would make lazy.nvim intercept every <Tab> press pre-load. The
	-- vim.keymap.set("<C-i>", ...) call below still works once harpoon has
	-- loaded via any of the other triggers.
	keys = { "<leader>a", "<C-e>", "<C-y>", "<C-n>", "<C-s>", "<C-S-P>", "<C-S-N>" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({
			settings = {
				save_on_toggle = true,
				save_on_change = true,
			},
		})

		-- Add file to harpoon list
		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end, { desc = "Harpoon: add file" })

		-- Toggle quick menu
		vim.keymap.set("n", "<C-e>", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end, { desc = "Harpoon: toggle menu" })

		-- Quick select marked files (1-4)
		vim.keymap.set("n", "<C-y>", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon: file 1" })
		vim.keymap.set("n", "<C-i>", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon: file 2" })
		vim.keymap.set("n", "<C-n>", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon: file 3" })
		vim.keymap.set("n", "<C-s>", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon: file 4" })

		-- Navigate previous & next in harpoon list
		vim.keymap.set("n", "<C-S-P>", function()
			harpoon:list():prev()
		end, { desc = "Harpoon: prev file" })
		vim.keymap.set("n", "<C-S-N>", function()
			harpoon:list():next()
		end, { desc = "Harpoon: next file" })
	end,
}
