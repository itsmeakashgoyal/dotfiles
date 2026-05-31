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
