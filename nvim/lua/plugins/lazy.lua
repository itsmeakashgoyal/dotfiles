-- Install lazylazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
        lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- check if firenvim is active
local firenvim_not_active = function() return not vim.g.started_by_firenvim end

-- Fixes Notify opacity issues
vim.o.termguicolors = true

require('lazy').setup({
    {
        'MeanderingProgrammer/markdown.nvim',
        main = "render-markdown",
        opts = {},
        name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
        dependencies = {
            'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons'
        } -- if you use the mini.nvim suite
    }, {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = {"nvim-lua/plenary.nvim"}
    }, {"mistricky/codesnap.nvim", build = "make"}, {
        "NeogitOrg/neogit",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim", -- required
            "sindrets/diffview.nvim", -- optional - Diff integration
            "nvim-telescope/telescope.nvim" -- optional
        },
        config = true
    }, 'onsails/lspkind.nvim', {
        "iamcco/markdown-preview.nvim",
        cmd = {
            "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop"
        },
        ft = {"markdown"},
        build = function() vim.fn["mkdp#util#install"]() end
    }, 'folke/zen-mode.nvim', 'tpope/vim-obsession', -- Tree
    -- {
    --   "nvim-tree/nvim-tree.lua",
    --   version = "*",
    --   lazy = true,
    --   requires = {
    --     "nvim-tree/nvim-web-devicons",
    --   },
    --   config = function()
    --     require("nvim-tree").setup({
    --       vim.api.nvim_set_keymap("n", "ff", ":NvimTreeToggle<enter>", { noremap=false }) 
    --       -- vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle file explorer on current file" }) 
    --       -- vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) 
    --       -- vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) 
    --     })
    --   end,
    -- },
    'ThePrimeagen/git-worktree.nvim', "tpope/vim-surround",
    'xiyaowong/nvim-transparent', {
        'rmagatti/goto-preview',
        config = function()
            require('goto-preview').setup {
                width = 120, -- Width of the floating window
                height = 15, -- Height of the floating window
                border = {
                    "↖", "─", "┐", "│", "┘", "─", "└", "│"
                }, -- Border characters of the floating window
                default_mappings = true,
                debug = false, -- Print debug information
                opacity = nil, -- 0-100 opacity level of the floating window where 100 is fully transparent.
                resizing_mappings = false, -- Binds arrow keys to resizing the floating window.
                post_open_hook = nil, -- A function taking two arguments, a buffer and a window to be ran as a hook.
                references = { -- Configure the telescope UI for slowing the references cycling window.
                    telescope = require("telescope.themes").get_dropdown({
                        hide_preview = false
                    })
                },
                -- These two configs can also be passed down to the goto-preview definition and implementation calls for one off "peak" functionality.
                focus_on_open = true, -- Focus the floating window when opening it.
                dismiss_on_move = false, -- Dismiss the floating window when moving the cursor.
                force_close = true, -- passed into vim.api.nvim_win_close's second argument. See :h nvim_win_close
                bufhidden = "wipe", -- the bufhidden option to set on the floating window. See :h bufhidden
                stack_floating_preview_windows = true, -- Whether to nest floating windows
                preview_window_title = {enable = true, position = "left"} -- Whether 
            }
        end
    }, {
        "folke/trouble.nvim",
        lazy = false,
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("trouble").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end
    }, {
        "folke/todo-comments.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require("todo-comments").setup {
                keywords = {
                    FIX = {
                        icon = " ",
                        color = "error",
                        alt = {"FIXME", "BUG", "FIXIT", "ISSUE"}
                    },
                    TODO = {icon = " ", color = "info"},
                    HACK = {icon = " ", color = "warning"},
                    WARN = {
                        icon = " ",
                        color = "warning",
                        alt = {"WARNING", "XXX"}
                    },
                    PERF = {
                        icon = " ",
                        alt = {"OPTIM", "PERFORMANCE", "OPTIMIZE"}
                    },
                    NOTE = {icon = " ", color = "hint", alt = {"INFO"}},
                    TEST = {
                        icon = "⏲ ",
                        color = "test",
                        alt = {"TESTING", "PASSED", "FAILED"}
                    }
                },
                gui_style = {
                    fg = "NONE", -- The gui style to use for the fg highlight group.
                    bg = "BOLD" -- The gui style to use for the bg highlight group.
                },
                merge_keywords = true, -- when true, custom keywords will be merged with the defaults
                highlight = {
                    multiline = true, -- enable multine todo comments
                    multiline_pattern = "^.", -- lua pattern to match the next multiline from the start of the matched keyword
                    multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
                    before = "", -- "fg" or "bg" or empty
                    keyword = "wide", -- "fg", "bg", "wide", "wide_bg", "wide_fg" or empty.
                    after = "fg", -- "fg" or "bg" or empty
                    pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlighting (vim regex)
                    comments_only = true, -- uses treesitter to match keywords in comments only
                    max_line_len = 400, -- ignore lines longer than this
                    exclude = {} -- list of file types to exclude highlighting
                },
                -- list of highlight groups or use the hex color if hl not found as a fallback
                colors = {
                    error = {"DiagnosticError", "ErrorMsg", "#DC2626"},
                    warning = {"DiagnosticWarn", "WarningMsg", "#FBBF24"},
                    info = {"DiagnosticInfo", "#2563EB"},
                    hint = {"DiagnosticHint", "#10B981"},
                    default = {"Identifier", "#7C3AED"},
                    test = {"Identifier", "#FF00FF"}
                }
            }
        end
    }, {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup({
                background_colour = "#000000",
                enabled = false
            })
        end
    }, {
        "folke/noice.nvim",
        config = function()
            require("noice").setup({
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true
                    }
                },
                -- you can enable a preset for easier configuration
                presets = {
                    bottom_search = true, -- use a classic bottom cmdline for search
                    command_palette = true, -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false, -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = true -- add a border to hover docs and signature help
                }
                -- cmdline = {
                --     view = "cmdline",
                -- },
            })
        end,
        dependencies = { -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim", "rcarriga/nvim-notify"
        }
    }, 'ray-x/go.nvim', 'ray-x/guihua.lua',
    {"catppuccin/nvim", as = "catppuccin"}, {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function() require("nvim-autopairs").setup {} end
    }, { -- LSP Configuration & Plugins
        'neovim/nvim-lspconfig',
        dependencies = { -- Automatically install LSPs to stdpath for neovim
            'williamboman/mason.nvim', 'williamboman/mason-lspconfig.nvim', -- Useful status updates for LSP
            'j-hui/fidget.nvim'
        }
    }, {
        -- Autocompletion
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip",

            -- Adds LSP completion capabilities
            "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline",

            -- Adds a number of user-friendly snippets
            "rafamadriz/friendly-snippets", -- Adds vscode-like pictograms
            "onsails/lspkind.nvim"
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            -- local lspkind = require("lspkind")

            local kind_icons = {
                Text = "",
                Method = "󰆧",
                Function = "󰊕",
                Constructor = "",
                Field = "󰇽",
                Variable = "󰂡",
                Class = "󰠱",
                Interface = "",
                Module = "",
                Property = "󰜢",
                Unit = "",
                Value = "󰎠",
                Enum = "",
                Keyword = "󰌋",
                Snippet = "",
                Color = "󰏘",
                File = "󰈙",
                Reference = "",
                Folder = "󰉋",
                EnumMember = "",
                Constant = "󰏿",
                Struct = "",
                Event = "",
                Operator = "󰆕",
                TypeParameter = "󰅲"
            }
            require("luasnip.loaders.from_vscode").lazy_load()
            luasnip.config.setup({})

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                completion = {completeopt = "menu,menuone,noinsert"},
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete({}),
                    ["<C-y>"] = cmp.mapping.confirm({select = true}),
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true
                    }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_locally_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, {"i", "s"}),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.locally_jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, {"i", "s"})
                }),
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered()
                },
                sources = {
                    {name = "nvim_lsp"}, {name = "nvim_lua"},
                    {name = "luasnip"}, {name = "buffer"}, {name = "path"},
                    {name = "calc"}, {name = "emoji"}, {name = "treesitter"},
                    {name = "crates"}, {name = "tmux"}
                },
                formatting = {
                    format = function(entry, vim_item)
                        local lspkind_ok, lspkind = pcall(require, "lspkind")
                        if not lspkind_ok then
                            -- From kind_icons array
                            vim_item.kind =
                                string.format("%s %s",
                                              kind_icons[vim_item.kind],
                                              vim_item.kind)
                            -- Source
                            vim_item.menu = ({
                                nvim_lsp = "[LSP]",
                                nvim_lua = "[Lua]",
                                luasnip = "[LuaSnip]",
                                buffer = "[Buffer]",
                                latex_symbols = "[LaTeX]"
                            })[entry.source.name]
                            return vim_item
                        else
                            -- From lspkind
                            return lspkind.cmp_format()(entry, vim_item)
                        end
                    end
                },

                -- `/` cmdline setup.
                cmp.setup.cmdline('/', {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = {{name = 'buffer'}}
                }),

                -- `:` cmdline setup.
                cmp.setup.cmdline(':', {
                    mapping = cmp.mapping.preset.cmdline(),
                    sources = cmp.config.sources({{name = 'path'}}, {
                        {
                            name = 'cmdline',
                            option = {ignore_cmds = {'Man', '!'}}
                        }
                    })
                })
            })
        end
    }, { -- Highlight, edit, and navigate code
        'nvim-treesitter/nvim-treesitter',
        build = function()
            pcall(require('nvim-treesitter.install').update {with_sync = true})
        end,
        dependencies = {'nvim-treesitter/nvim-treesitter-textobjects'}
    }, {
        "rcarriga/nvim-dap-ui",
        dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"}
    }, 'theHamsta/nvim-dap-virtual-text', 'leoluz/nvim-dap-go', -- Git related plugins
    'tpope/vim-fugitive', 'lewis6991/gitsigns.nvim',
    'nvim-lualine/lualine.nvim', -- Fancier statusline
    {"lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {}}, {
        'numToStr/Comment.nvim', -- "gc" to comment visual regions/lines 
        event = {"BufRead", "BufNewFile"},
        config = true
    }, 'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
    -- Fuzzy Finder (files, lsp, etc)
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {'nvim-lua/plenary.nvim'}
    }, 'nvim-telescope/telescope-symbols.nvim',
    -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable 'make' == 1
    }, {
        "folke/twilight.nvim",
        ft = "markdown",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    }, -- fancy start screen
    --   {
    --   'nvimdev/dashboard-nvim',
    --   event = 'VimEnter',
    --   config = function()
    --     require("plugins.dashboard-nvim")
    --   end,
    --   dependencies = { {'nvim-tree/nvim-web-devicons'}}
    -- }
    {
        'fei6409/log-highlight.nvim',
        config = function() require('log-highlight').setup {} end
    }, {
        "echasnovski/mini.nvim",
        config = function()
            -- Better Around/Inside textobjects
            --
            -- Examples:
            --  - va)  - [V]isually select [A]round [)]paren
            --  - yinq - [Y]ank [I]nside [N]ext [']quote
            --  - ci'  - [C]hange [I]nside [']quote
            require("mini.ai").setup({n_lines = 500})

            -- Add/delete/replace surroundings (brackets, quotes, etc.)
            --
            -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
            -- - sd'   - [S]urround [D]elete [']quotes
            -- - sr)'  - [S]urround [R]eplace [)] [']
            require("mini.surround").setup()

            require("mini.pairs").setup()

            -- local statusline = require("mini.statusline")
            -- statusline.setup({
            --   use_icons = vim.g.have_nerd_font,
            -- })
            -- ---@diagnostic disable-next-line: duplicate-set-field
            -- statusline.section_location = function()
            --   return "%2l:%-2v"
            -- end
        end
    }, {
        "echasnovski/mini.icons",
        enabled = true,
        opts = {},
        lazy = true
        -- specs = {
        --   { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
        -- },
        -- init = function()
        --   package.preload["nvim-web-devicons"] = function()
        --     -- needed since it will be false when loading and mini will fail
        --     package.loaded["nvim-web-devicons"] = {}
        --     require("mini.icons").mock_nvim_web_devicons()
        --     return package.loaded["nvim-web-devicons"]
        --   end
        -- end,
    }, -- Add/change/delete surrounding delimiter pairs with ease
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function() require("nvim-surround").setup() end
    }, -- find and replace
    {
        "windwp/nvim-spectre",
        enabled = false,
        event = "BufRead",
        keys = {
            {
                "<leader>Rr",
                function() require("spectre").open() end,
                desc = "Replace"
            }, {
                "<leader>Rw",
                function()
                    require("spectre").open_visual({select_word = true})
                end,
                desc = "Replace Word"
            }, {
                "<leader>Rf",
                function() require("spectre").open_file_search() end,
                desc = "Replace Buffer"
            }
        }
    },
    {
        "sbdchd/neoformat",
        config = function()
            -- vim.api.nvim_create_autocmd({ "BufWritePre", "TextChanged" }, {
            vim.api.nvim_create_autocmd(
                {"BufWritePre"},
                {
                    pattern = {
                        "*.json",
                        "*.yml",
                        "*.yaml",
                        "*.js",
                        "*.ts",
                        "*.lua",
                        "*.cpp",
                        "*.hpp",
                        "*.cxx",
                        "*.hxx",
                        "*.cc",
                        "*.c",
                        "*.h",
                        "*.rs",
                        "*.py"
                    },
                    command = "Neoformat"
                }
            )
        end
    },
    -- Autotags
    {"windwp/nvim-ts-autotag", opts = {}}, {
        "goolord/alpha-nvim",
        -- dependencies = { 'echasnovski/mini.icons' },
        dependencies = {'nvim-tree/nvim-web-devicons'},
        config = function()
            -- local startify = require("alpha.themes.startify")
            -- -- available: devicons, mini, default is mini
            -- -- if provider not loaded and enabled is true, it will try to use another provider
            -- startify.file_icons.provider = "devicons"
            -- require("alpha").setup(
            --   startify.config
            -- )

            local dashboard = require("alpha.themes.dashboard")
            local logo = [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]
            dashboard.section.header.val = vim.split(logo, "\n")
            dashboard.section.buttons.val = {
                dashboard.button("f", " " .. " Find file",
                                 ":Telescope find_files <CR>"),
                -- dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("r", " " .. " Recent files",
                                 ":Telescope oldfiles <CR>"),
                dashboard.button("g", " " .. " Find text",
                                 ":Telescope live_grep <CR>"),
                -- dashboard.button("s", " " .. "Restore Session", '<cmd>lua require("persistence").load()<cr>'),
                -- dashboard.button("c", " " .. " Config", ":e ~/.config/nvim/ <CR>"),
                dashboard.button("l", "󰒲 " .. " Lazy", ":Lazy<CR>"),
                dashboard.button("q", " " .. " Quit", ":qa<CR>")
            }

            for _, button in ipairs(dashboard.section.buttons.val) do
                button.opts.hl = "AlphaButtons"
                button.opts.hl_shortcut = "AlphaShortcut"
            end
            dashboard.section.header.opts.hl = "AlphaHeader"
            dashboard.section.buttons.opts.hl = "AlphaButtons"
            dashboard.section.footer.opts.hl = "AlphaFooter"
            dashboard.opts.layout[1].val = 8

            require("alpha").setup(dashboard.config)

            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyVimStarted",
                callback = function()
                    local stats = require("lazy").stats()
                    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                    dashboard.section.footer.val =
                        "⚡ Neovim loaded " .. stats.count .. " plugins in " ..
                            ms .. "ms"
                    pcall(vim.cmd.AlphaRedraw)
                end
            })
        end
    }
})
