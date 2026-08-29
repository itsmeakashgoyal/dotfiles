--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/csvview.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Csvview: aligns CSV/TSV columns into a readable table view, toggleable.
return {
	"hat0uma/csvview.nvim",
	ft = { "csv", "tsv" },
	opts = {
		parser = { comments = { "#", "//" } },
	},
	keys = {
		{
			"<leader>uv",
			function()
				require("csvview").toggle({ display_mode = "border" })
			end,
			desc = "Toggle CSV view",
		},
	},
}
