--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/plugins/auto-pairs.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Auto-pairs: automatically closes brackets and quotes.
return {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    config = function()
        local autopairs = require("nvim-autopairs") -- import nvim-autopairs

        -- setup autopairs
        autopairs.setup({
            check_ts = true, -- treesitter enabled
            ts_config = {
                lua = { "string" }, -- dont add pairs in lua string treesitter nodes
                javascript = { "template_string" }, -- dont add pairs in javscript template_string treesitter nodes
                java = false, -- dont check treesitter on java
            },
        })
    end,
}
