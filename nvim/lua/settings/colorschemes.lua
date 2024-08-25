-- Colorschemes settings
require("catppuccin").setup {
    flavour = "mocha", -- auto, latte, frappe, macchiato, mocha
    background = {
        -- :h background
        light = "latte",
        dark = "mocha"
    },
    transparent_background = false, -- disables setting the background color.
    show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
    term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
    dim_inactive = {
        enabled = false, -- dims the background color of inactive window
        shade = "dark",
        percentage = 0.15 -- percentage of the shade to apply to the inactive window
    },
    no_italic = false, -- Force no italic
    no_bold = false, -- Force no bold
    no_underline = false, -- Force no underline
    styles = {
        -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = {"italic"}, -- Change the style of comments
        conditionals = {"italic"},
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {}
        -- miscs = {}, -- Uncomment to turn off hard-coded styles
    },
    color_overrides = {},
    custom_highlights = {},
    default_integrations = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = true,
        telescope = true,
        mini = {
            enabled = true,
            indentscope_color = ""
        }
        -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
    }
}

require("tokyonight").setup {
    style = "night", -- The theme comes in three styles, `storm`, a darker variant `night` and `day`
    transparent = false, -- Enable this to disable setting the background color
    terminal_colors = true
}

require("nightfox").setup {
    options = {
        transparent = false,
        terminal_colors = true,
        dim_inactive = true
    },
    modules = {
        telescope = true,
        treesitter = true,
        gitgutter = true
    }
}

vim.cmd [[
let g:PaperColor_Theme_Options = {
  \   'theme': {
  \     'default.dark': {
  \       'transparent_background': 0
  \     }
  \   }
  \ }
]]

require("transparent").setup {
    extra_groups = {
        -- table/string: additional groups that should be cleared
        -- In particular, when you set it to 'all', that means all available groups
        -- example of akinsho/nvim-bufferline.lua
        "BufferLineTabClose",
        "BufferlineBufferSelected",
        "BufferLineFill",
        "BufferLineBackground",
        "BufferLineSeparator",
        "BufferLineIndicatorSelected",
        "Telescope"
    }
}

vim.opt.fillchars = {
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋"
}
vim.g.termigurcolors = true
-- Active colorscheme
-- vim.cmd('colorscheme moonfly')
vim.cmd "colorscheme catppuccin"
-- vim.cmd('colorscheme nightfox')
-- vim.cmd('colorscheme tokyonight-night')
-- vim.cmd('colorscheme carbonfox')
