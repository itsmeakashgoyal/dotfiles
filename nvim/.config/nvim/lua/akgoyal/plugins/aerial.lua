--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/aerial.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Aerial: code outline / symbol navigation sidebar.
return {
	"stevearc/aerial.nvim",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle code outline" },
		{ "[s", "<cmd>AerialPrev<CR>", desc = "Prev symbol" },
		{ "]s", "<cmd>AerialNext<CR>", desc = "Next symbol" },
	},
	opts = {
		backends = { "treesitter", "lsp", "markdown", "man" },
		layout = {
			max_width = { 40, 0.2 },
			min_width = 20,
		},
		attach_mode = "global",
		filter_kind = false,
	},
}
