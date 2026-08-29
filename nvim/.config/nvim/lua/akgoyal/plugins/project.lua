--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/project.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Project: detects project roots (git/LSP/patterns) and lists recent projects via a telescope picker.
return {
	"ahmedkhalf/project.nvim",
	event = "VeryLazy",
	config = function()
		require("project_nvim").setup({
			detection_methods = { "pattern", "lsp" },
			patterns = { ".git", "Makefile", "CMakeLists.txt", "pyproject.toml", "Cargo.toml", "go.mod" },
		})
		require("telescope").load_extension("projects")
	end,
	keys = {
		{
			"<leader>pp",
			function()
				require("telescope").extensions.projects.projects()
			end,
			desc = "Projects",
		},
	},
}
