--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/cloak.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Cloak: masks sensitive values (e.g. .env secrets) in buffers, toggleable on demand.
return {
	"laytan/cloak.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{ "<leader>ue", "<cmd>CloakToggle<CR>", desc = "Toggle env cloak" },
	},
}
