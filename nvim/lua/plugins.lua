-- Bootstrap lazy.nvim
-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system {"git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath}
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup {
    -- AI {{{
    "github/copilot.vim",
    "robitx/gp.nvim",
    "MunifTanjim/nui.nvim", -- }}}
    -- Editor Extensions {{{
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        -- stylua: ignore
        keys = {
            {
                "s",
                mode = {"n", "x", "o"},
                function()
                    require("flash").jump()
                end,
                desc = "Flash"
            },
            {
                "r",
                mode = "o",
                function()
                    require("flash").remote()
                end,
                desc = "Remote Flash"
            },
            {
                "<c-s>",
                mode = {"c"},
                function()
                    require("flash").toggle()
                end,
                desc = "Toggle Flash Search"
            }
        }
    },
    "stefandtw/quickfix-reflector.vim",
    "jbyuki/one-small-step-for-vimkind",
    {
        "michaelb/sniprun",
        build = "sh ./install.sh",
        opts = {
            display = {"Classic"}
        }
    },
    {
        "alexghergh/nvim-tmux-navigation",
        opts = {
            disable_when_zoomed = true
        }
    },
    "romainl/vim-cool",
    "yssl/QFEnter",
    "jesseleite/nvim-macroni",
    "3rd/image.nvim",
    "nosduco/remote-sshfs.nvim",
    "nvim-neotest/neotest-python",
    {
        "nvim-neotest/neotest-plenary",
        lazy = true
    },
    {
        "nvim-lua/plenary.nvim",
        lazy = true
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        -- Optional dependency
        dependencies = {"hrsh7th/nvim-cmp"},
        config = function()
            require("nvim-autopairs").setup {}
            -- If you want to automatically add `(` after selecting a function or method
            local cmp_autopairs = require "nvim-autopairs.completion.cmp"
            local cmp = require "cmp"
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end
    },
    "jonarrien/telescope-cmdline.nvim",
    {
        "chrisgrieser/nvim-various-textobjs",
        opts = {}
    },
    {
        "wintermute-cell/gitignore.nvim",
        dependencies = "nvim-telescope/telescope.nvim"
    },
    "ionide/Ionide-vim",
    "rcarriga/nvim-notify",
    "marcelofern/vale.nvim",
    "karoliskoncevicius/vim-sendtowindow",
    "tpope/vim-rhubarb",
    "nvim-neotest/nvim-nio",
    "David-Kunz/gen.nvim",
    "RRethy/nvim-align",
    "vim-scripts/scrollfix",
    "echasnovski/mini.nvim",
    "mattn/emmet-vim",
    "mhinz/vim-startify",
    "preservim/nerdcommenter",
    "tpope/vim-fugitive",
    "Piotr1215/telescope-crossplane.nvim",
    {
        "jiaoshijie/undotree",
        opts = {}
    },
    {
        "kylechui/nvim-surround",
        opts = {}
    },
    "folke/which-key.nvim",
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        opts = {}
    },
    "austintaylor/vim-commaobject",
    "ferrine/md-img-paste.vim", -- 'https://gitlab.com/madyanov/svart.nvim',
    "kevinhwang91/nvim-bqf", -- better quickfix window
    -- }}}
    -- System Integration {{{
    {
        "junegunn/fzf",
        build = "./install --bin"
    },
    "junegunn/fzf.vim",
    "mfussenegger/nvim-lint",
    "nvim-tree/nvim-web-devicons", -- optional, for file icon
    -- }}}
    -- Telescope {{{
    "danielpieper/telescope-tmuxinator.nvim",
    "jvgrootveld/telescope-zoxide",
    {
        "ellisonleao/glow.nvim",
        opts = {}
    },
    "xiyaowong/telescope-emoji.nvim",
    "nvim-telescope/telescope-symbols.nvim",
    "cljoly/telescope-repo.nvim",
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {{"nvim-lua/popup.nvim"}, {"nvim-telescope/telescope-live-grep-args.nvim"}}
    },
    {"nvim-telescope/telescope-file-browser.nvim"},
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make"
    },
    "smartpde/telescope-recent-files", -- }}}
    -- LSP {{{
    "ray-x/lsp_signature.nvim",
    "ibhagwan/fzf-lua",
    -- Highlight, edit, and navigate code
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate"
    },
    "onsails/lspkind-nvim",
    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {"clangd", "clang-format", "codelldb"}
        }
    },
    "williamboman/mason-lspconfig.nvim",
    {
        -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        {
            "folke/lazydev.nvim",
            ft = "lua", -- only load on lua files
            opts = {
                library = {
                    -- See the configuration section for more details
                    -- Load luvit types when the `vim.uv` word is found
                    {
                        path = "luvit-meta/library",
                        words = {"vim%.uv"}
                    }
                }
            }
        },
        {
            "Bilal2453/luvit-meta",
            lazy = true
        }, -- optional `vim.uv` typings
        {
            -- optional completion source for require statements and module annotations
            "hrsh7th/nvim-cmp",
            opts = function(_, opts)
                opts.sources = opts.sources or {}
                snippet = {
                    expand = function(args)
                        require'luasnip'.lsp_expand(args.body)
                    end
                },
                table.insert(
                    opts.sources,
                    {
                        name = { 'lazydev', 'luasnip'},
                        group_index = 0 -- set group index to 0 to skip loading LuaLS completions
                    }
                )
            end
        } -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
    },
    "neovim/nvim-lspconfig",
    {
        "folke/trouble.nvim",
        dependencies = {
            -- Automatically install LSPs and related tools to stdpath for Neovim
            {"williamboman/mason.nvim", config = true}, -- NOTE: Must be loaded before dependants
            "williamboman/mason-lspconfig.nvim",
            "kyazdani42/nvim-web-devicons",
            "WhoIsSethDaniel/mason-tool-installer.nvim",
            -- Useful status updates for LSP.
            -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
            {"j-hui/fidget.nvim", opts = {}},
            -- Allows extra capabilities provided by nvim-cmp
            "hrsh7th/cmp-nvim-lsp"
        },
        opts = {}
    },
    {
        "folke/noice.nvim",
        config = function()
            require("noice").setup(
                {
                    -- add any options here
                    routes = {
                        {
                            filter = {
                                event = "msg_show",
                                any = {
                                    {
                                        find = "%d+L, %d+B"
                                    },
                                    {
                                        find = "; after #%d+"
                                    },
                                    {
                                        find = "; before #%d+"
                                    },
                                    {
                                        find = "%d fewer lines"
                                    },
                                    {
                                        find = "%d more lines"
                                    }
                                }
                            },
                            opts = {
                                skip = true
                            }
                        }
                    }
                }
            )
        end,
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim", -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify"
        }
    },
    "hrsh7th/cmp-nvim-lsp-signature-help",
    {
        "hrsh7th/cmp-vsnip",
        dependencies = {"hrsh7th/vim-vsnip", "rafamadriz/friendly-snippets"}
    },
    {
        "shortcuts/no-neck-pain.nvim",
        version = "*"
    },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter"
        }
    },
    -- Snippets {{{
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "nvim-treesitter",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline"
        }
    },
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/vim-vsnip",
    "hrsh7th/vim-vsnip-integ", -- }}}
    -- Programming {{{
    "ii14/neorepl.nvim",
    "stevearc/dressing.nvim",
    {
        "saecki/crates.nvim",
        opts = {}
    },
    "simrat39/rust-tools.nvim",
    "IndianBoy42/tree-sitter-just",
    "ray-x/go.nvim",
    "ray-x/guihua.lua", -- recommended if need floating window support
    "rmagatti/goto-preview",
    "nvim-treesitter/nvim-treesitter-textobjects", -- }}}
    -- Markdown {{{
    "jubnzv/mdeval.nvim",
    {
        "AckslD/nvim-FeMaco.lua",
        config = 'require("femaco").setup()'
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
    "ixru/nvim-markdown",
    "javiorfo/nvim-soil",
    -- Optional for puml syntax highlighting:
    "javiorfo/nvim-nyctophilia",
    "weirongxu/plantuml-previewer.vim",
    -- }}}
    -- Look & Feel {{{
    "ellisonleao/gruvbox.nvim",
    "mhartington/formatter.nvim",
    "ryanoasis/vim-devicons",
    "xiyaowong/nvim-transparent",
    "kdheepak/monochrome.nvim",
    "EdenEast/nightfox.nvim",
    "NLKNguyen/papercolor-theme",
    "folke/tokyonight.nvim",
    "rktjmp/lush.nvim",
    {
        "catppuccin/nvim",
        as = "catppuccin"
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {"nvim-tree/nvim-web-devicons"}
    }, -- }}}
    {
        "epwalsh/obsidian.nvim",
        version = "*"
    },
    "f-person/git-blame.nvim",
    -- NOTE: Plugins can also be added by using a table,
    -- with the first argument being the link and the following
    -- keys can be used to configure plugin behavior/loading/etc.
    --
    -- Use `opts = {}` to force a plugin to be loaded.
    --

    -- Here is a more advanced example where we pass configuration
    -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
    --    require('gitsigns').setup({ ... })
    --
    -- See `:help gitsigns` to understand what the configuration keys do
    {
        -- Adds git related signs to the gutter, as well as utilities for managing changes
        "lewis6991/gitsigns.nvim",
        opts = {
            signs = {
                add = {text = "+"},
                change = {text = "~"},
                delete = {text = "_"},
                topdelete = {text = "‾"},
                changedelete = {text = "~"}
            }
        }
    },
    {
        "fei6409/log-highlight.nvim",
        config = function()
            require("log-highlight").setup {}
        end
    },
    {
        "stevearc/conform.nvim",
        event = {"BufWritePre"},
        cmd = {"ConformInfo"},
        keys = {
            {
                "<leader>f",
                function()
                    require("conform").format {async = true, lsp_fallback = true}
                end,
                mode = "",
                desc = "[F]ormat buffer"
            }
        }
    },
    -- Highlight todo, notes, etc in comments
    {"folke/todo-comments.nvim", event = "VimEnter", dependencies = {"nvim-lua/plenary.nvim"}, opts = {signs = false}},
    {
        -- NOTE: Yes, you can install new plugins here!
        "mfussenegger/nvim-dap",
        -- NOTE: And you can specify dependencies as well
        dependencies = {
            -- Creates a beautiful debugger UI
            "rcarriga/nvim-dap-ui",
            -- Required dependency for nvim-dap-ui
            "nvim-neotest/nvim-nio",
            -- Installs the debug adapters for you
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
            -- Add your own debuggers here
            "leoluz/nvim-dap-go"
        },
        keys = function(_, keys)
            local dap = require "dap"
            local dapui = require "dapui"
            return {
                -- Basic debugging keymaps, feel free to change to your liking!
                {"<F5>", dap.continue, desc = "Debug: Start/Continue"},
                {"<F1>", dap.step_into, desc = "Debug: Step Into"},
                {"<F2>", dap.step_over, desc = "Debug: Step Over"},
                {"<F3>", dap.step_out, desc = "Debug: Step Out"},
                {"<leader>b", dap.toggle_breakpoint, desc = "Debug: Toggle Breakpoint"},
                {
                    "<leader>B",
                    function()
                        dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
                    end,
                    desc = "Debug: Set Breakpoint"
                },
                -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
                {"<F7>", dapui.toggle, desc = "Debug: See last session result."},
                unpack(keys)
            }
        end
    },
    -------- snippets --------
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        -- install jsregexp (optional!).
        build = "make install_jsregexp"
    },
    { 'honza/vim-snippets' },
    { 'saadparwaiz1/cmp_luasnip' },
}, {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or
            {
                cmd = "⌘",
                config = "🛠",
                event = "📅",
                ft = "📂",
                init = "⚙",
                keys = "🗝",
                plugin = "🔌",
                runtime = "💻",
                require = "🌙",
                source = "📄",
                start = "🚀",
                task = "📌",
                lazy = "💤 "
            }
    }
}
