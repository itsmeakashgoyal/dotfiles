return {
	"ThePrimeagen/refactoring.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	keys = {
		{
			"<leader>Re",
			function()
				require("refactoring").refactor("Extract Function")
			end,
			mode = "x",
			desc = "Extract function",
		},
		{
			"<leader>Rv",
			function()
				require("refactoring").refactor("Extract Variable")
			end,
			mode = "x",
			desc = "Extract variable",
		},
		{
			"<leader>Ri",
			function()
				require("refactoring").refactor("Inline Variable")
			end,
			mode = { "n", "x" },
			desc = "Inline variable",
		},
		{
			"<leader>Rf",
			function()
				require("refactoring").refactor("Extract Block")
			end,
			desc = "Extract block",
		},
		{
			"<leader>RF",
			function()
				require("refactoring").refactor("Extract Block To File")
			end,
			desc = "Extract block to file",
		},
		{
			"<leader>Rs",
			function()
				require("telescope").extensions.refactoring.refactors()
			end,
			mode = { "n", "x" },
			desc = "Select refactoring",
		},
	},
	config = function()
		require("refactoring").setup({})
		require("telescope").load_extension("refactoring")
	end,
}
