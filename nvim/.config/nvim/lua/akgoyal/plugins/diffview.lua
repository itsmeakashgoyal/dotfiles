return {
	"sindrets/diffview.nvim",
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
	keys = {
		{
			"<leader>gd",
			function()
				local lib = require("diffview.lib")
				local view = lib.get_current_view()
				if view then
					vim.cmd("DiffviewClose")
				else
					vim.cmd("DiffviewOpen")
				end
			end,
			desc = "Toggle Diffview",
		},
		{ "<leader>gD", "<cmd>DiffviewFileHistory %<CR>", desc = "File history (current file)" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "File history (repo)" },
	},
	opts = {
		view = {
			default = { layout = "diff2_horizontal" },
			merge_tool = { layout = "diff3_mixed" },
		},
	},
}
