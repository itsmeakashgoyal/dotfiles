--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/mini-surround.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Mini.surround: add, delete, and replace surrounding pairs (quotes, brackets, tags) via sa/sd/sr.
return {
	"echasnovski/mini.surround",
	version = "*",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		mappings = {
			add = "sa",
			delete = "sd",
			find = "sf",
			find_left = "sF",
			highlight = "sH",
			replace = "sr",
			update_n_lines = "sn",
		},
	},
}
