return {
	"linux-cultist/venv-selector.nvim",
	branch = "regexp",
	ft = "python",
	dependencies = {
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{ "<leader>vs", "<cmd>VenvSelect<CR>", desc = "Select Python venv" },
	},
	opts = {},
}
