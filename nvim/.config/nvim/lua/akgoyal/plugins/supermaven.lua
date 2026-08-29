--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/supermaven.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Supermaven: AI-powered inline code completion suggestions.
return {
	"supermaven-inc/supermaven-nvim",
	event = "InsertEnter",
	opts = {
		keymaps = {
			accept_suggestion = "<C-l>",
			clear_suggestion = "<C-]>",
			accept_word = "<C-Right>",
		},
		ignore_filetypes = { "oil", "help", "dashboard" },
		color = {
			suggestion_color = "#928374", -- gruvbox gray
			cterm = 244,
		},
		log_level = "off",
	},
}
