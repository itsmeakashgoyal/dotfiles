--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/indent-blankline.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Indent-blankline: renders indentation guide lines and highlights the current scope.
return {
	"lukas-reineke/indent-blankline.nvim",
	event = { "BufReadPre", "BufNewFile" },
	main = "ibl",
	opts = {
		indent = {
			char = "│",
			tab_char = "│",
		},
		scope = {
			enabled = true,
			show_start = true,
			show_end = false,
		},
		exclude = {
			filetypes = {
				"help",
				"dashboard",
				"lazy",
				"mason",
				"notify",
				"oil",
				"trouble",
			},
		},
	},
}
