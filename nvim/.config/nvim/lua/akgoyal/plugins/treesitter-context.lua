--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/treesitter-context.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Treesitter-context: shows a sticky header of the enclosing function/class scope while scrolling.
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	opts = {
		enable = true,
		max_lines = 3,
		min_window_height = 0,
		line_numbers = true,
		multiline_threshold = 20,
		trim_scope = "outer",
		mode = "cursor",
	},
	keys = {
		{
			"<leader>ct",
			function()
				require("treesitter-context").toggle()
			end,
			desc = "Toggle treesitter context",
		},
	},
}
