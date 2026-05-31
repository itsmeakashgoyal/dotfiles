return {
	"mistweaverco/kulala.nvim",
	ft = "http",
	keys = {
		{
			"<leader>kr",
			function()
				require("kulala").run()
			end,
			desc = "Run HTTP request",
			ft = "http",
		},
		{
			"<leader>ka",
			function()
				require("kulala").run_all()
			end,
			desc = "Run all HTTP requests",
			ft = "http",
		},
		{
			"<leader>kp",
			function()
				require("kulala").replay()
			end,
			desc = "Replay last request",
			ft = "http",
		},
	},
	opts = {},
}
