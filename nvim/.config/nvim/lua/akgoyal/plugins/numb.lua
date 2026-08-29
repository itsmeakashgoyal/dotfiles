--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/numb.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Numb: previews the target line in the buffer while typing a line-number jump command.
return {
	"nacro90/numb.nvim",
	event = "CmdlineEnter",
	config = true,
}
