-- nvim-cmp
local lspkind = require "lspkind"
local cmp = require "cmp"

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup {
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end
    },
    formatting = {
        expandable_indicator = true,
        fields = {"abbr", "kind", "menu"},
        format = lspkind.cmp_format {
            mode = "symbol_text", -- Use "symbol" to only show the icon or "symbol_text" for both icon and text
            maxwidth = 50, -- Optional, for max width of the displayed item
            ellipsis_char = "...", -- Optional, truncate the item if it's too long
            menu = {
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[Lua]",
                projects = "[Projects]",
                emoji = "[Emoji]",
                vsnip = "[Snippet]"
            }
        }
    },
    mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
        },
        ["<Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif vim.fn["vsnip#available"](1) == 1 then
                    feedkey("<Plug>(vsnip-expand-or-jump)", "")
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end,
            {"i", "s"}
        ),
        ["<S-Tab>"] = cmp.mapping(
            function()
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                    feedkey("<Plug>(vsnip-jump-prev)", "")
                end
            end,
            {"i", "s"}
        )
    },
    sources = {
        {
            name = "nvim_lsp"
        },
        {
            name = "nvim_lua",
            priority = 100
        },
        {
            name = "vsnip"
        },
        {
            name = "buffer"
        },
        {
            name = "emoji"
        },
        {
            name = "path"
        },
        {
            name = "crates"
        },
        {
            name = "snippets"
        },
        {
            name = "projects",
            priority = 100
        }
    }
}

-- Use buffer source for `/`
cmp.setup.cmdline(
    "/",
    {
        sources = {
            {
                name = "buffer"
            }
        }
    }
)

-- Use cmdline & path source for ':'
cmp.setup.cmdline(
    ":",
    {
        sources = cmp.config.sources(
            {
                {
                    name = "path"
                }
            },
            {
                {
                    name = "cmdline"
                }
            }
        )
    }
)

-- local highlight = {
--   "RainbowRed",
--   "RainbowYellow",
--   "RainbowBlue",
--   "RainbowOrange",
--   "RainbowGreen",
--   "RainbowViolet",
--   "RainbowCyan",
-- }

-- local hooks = require "ibl.hooks"
-- -- create the highlight groups in the highlight setup hook, so they are reset
-- -- every time the colorscheme changes
-- hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
--   vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
--   vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
--   vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
--   vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
--   vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
--   vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
--   vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
-- end)

-- require("ibl").setup { indent = { highlight = highlight } }

local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan"
}
local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(
    hooks.type.HIGHLIGHT_SETUP,
    function()
        vim.api.nvim_set_hl(
            0,
            "RainbowRed",
            {
                fg = "#E06C75"
            }
        )
        vim.api.nvim_set_hl(
            0,
            "RainbowYellow",
            {
                fg = "#E5C07B"
            }
        )
        vim.api.nvim_set_hl(
            0,
            "RainbowBlue",
            {
                fg = "#61AFEF"
            }
        )
        vim.api.nvim_set_hl(
            0,
            "RainbowOrange",
            {
                fg = "#D19A66"
            }
        )
        vim.api.nvim_set_hl(
            0,
            "RainbowGreen",
            {
                fg = "#98C379"
            }
        )
        vim.api.nvim_set_hl(
            0,
            "RainbowViolet",
            {
                fg = "#C678DD"
            }
        )
        vim.api.nvim_set_hl(
            0,
            "RainbowCyan",
            {
                fg = "#56B6C2"
            }
        )
    end
)

vim.g.rainbow_delimiters = {
    highlight = highlight
}
require("ibl").setup {
    scope = {
        highlight = highlight
    }
}

hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)