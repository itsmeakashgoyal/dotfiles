--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/venv-selector.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Venv-selector: picks a Python virtualenv to use for the LSP, loaded for Python files.
return {
	"linux-cultist/venv-selector.nvim",
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
