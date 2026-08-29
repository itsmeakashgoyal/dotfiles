--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/dadbod.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Dadbod UI: database client for browsing and querying SQL databases from within Neovim.
return {
	"kristijanhusak/vim-dadbod-ui",
	dependencies = {
		{ "tpope/vim-dadbod", lazy = true },
		{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
	},
	cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
	keys = {
		{ "<leader>Db", "<cmd>DBUIToggle<CR>", desc = "Toggle DB UI" },
	},
	init = function()
		vim.g.db_ui_use_nerd_font_icons = 1
	end,
}
