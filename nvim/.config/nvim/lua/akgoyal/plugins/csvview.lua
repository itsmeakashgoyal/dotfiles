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
