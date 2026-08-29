--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/dial.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Dial: smart increment/decrement for numbers, dates, and booleans beyond plain integers.
return {
	"monaqa/dial.nvim",
	keys = {
		{
			"<C-a>",
			function()
				require("dial.map").manipulate("increment", "normal")
			end,
			desc = "Increment",
		},
		{
			"<C-x>",
			function()
				require("dial.map").manipulate("decrement", "normal")
			end,
			desc = "Decrement",
		},
		{
			"<C-a>",
			function()
				require("dial.map").manipulate("increment", "visual")
			end,
			mode = "v",
			desc = "Increment",
		},
		{
			"<C-x>",
			function()
				require("dial.map").manipulate("decrement", "visual")
			end,
			mode = "v",
			desc = "Decrement",
		},
	},
	config = function()
		local augend = require("dial.augend")
		require("dial.config").augends:register_group({
			default = {
				augend.integer.alias.decimal_int,
				augend.integer.alias.hex,
				augend.constant.alias.bool,
				augend.date.alias["%Y/%m/%d"],
				augend.date.alias["%Y-%m-%d"],
				augend.constant.new({ elements = { "true", "false" } }),
				augend.constant.new({ elements = { "True", "False" } }),
				augend.constant.new({ elements = { "yes", "no" } }),
				augend.constant.new({ elements = { "&&", "||" }, word = false }),
			},
		})
	end,
}
