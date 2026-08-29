--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/yanky.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Yanky: enhanced yank/put with a persistent history ring and a telescope-based yank-history picker.
return {
	"gbprod/yanky.nvim",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		ring = {
			history_length = 100,
			storage = "shada",
		},
		highlight = {
			on_put = true,
			on_yank = true,
			timer = 200,
		},
	},
	keys = {
		{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put after" },
		{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put before" },
		{ "[y", "<Plug>(YankyPreviousEntry)", desc = "Cycle yank prev" },
		{ "]y", "<Plug>(YankyNextEntry)", desc = "Cycle yank next" },
		{
			"<leader>yh",
			function()
				require("telescope").extensions.yank_history.yank_history()
			end,
			desc = "Yank History",
		},
	},
}
