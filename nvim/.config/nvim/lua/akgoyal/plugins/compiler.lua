--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/compiler.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Compiler: build/task runner UI backed by overseer.nvim, for compiling and running project tasks.
return {
	"Zeioth/compiler.nvim",
	cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo", "CompilerStop" },
	dependencies = {
		{
			"stevearc/overseer.nvim",
			opts = {
				task_list = {
					direction = "bottom",
					min_height = 10,
					max_height = 15,
					default_detail = 1,
				},
			},
		},
	},
	keys = {
		{ "<leader>Co", "<cmd>CompilerOpen<CR>", desc = "Compiler: Open" },
		{ "<leader>Cr", "<cmd>CompilerRedo<CR>", desc = "Compiler: Redo" },
		{ "<leader>Cs", "<cmd>CompilerStop<CR>", desc = "Compiler: Stop" },
		{ "<leader>Ct", "<cmd>CompilerToggleResults<CR>", desc = "Compiler: Toggle results" },
	},
	opts = {},
}
