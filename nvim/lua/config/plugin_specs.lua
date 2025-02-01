-- Install lazylazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system(
        {"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
         lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- check if firenvim is active
local firenvim_not_active = function()
    return not vim.g.started_by_firenvim
end

-- Fixes Notify opacity issues
vim.o.termguicolors = true

local plugin_specs = {{{
    "MeanderingProgrammer/markdown.nvim",
    main = "render-markdown",
    opts = {},
    name = "render-markdown", -- Only needed if you have another plugin named markdown.nvim
    dependencies = {"nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons"} -- if you use the mini.nvim suite
}, {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = {"nvim-lua/plenary.nvim"}
}, {
    "mistricky/codesnap.nvim",
    build = "make"
}, {
    "NeogitOrg/neogit",
    lazy = false,
    dependencies = {"nvim-lua/plenary.nvim", -- required
    "sindrets/diffview.nvim", -- optional - Diff integration
    "nvim-telescope/telescope.nvim" -- optional
    },
    config = true
}, "onsails/lspkind.nvim", {
    "iamcco/markdown-preview.nvim",
    cmd = {"MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop"},
    ft = {"markdown"},
    build = function()
        vim.fn["mkdp#util#install"]()
    end
}, "folke/zen-mode.nvim", "tpope/vim-obsession", -- Tree
"ThePrimeagen/git-worktree.nvim", {
    "rmagatti/goto-preview",
    config = function()
        require("goto-preview").setup({
            width = 120, -- Width of the floating window
            height = 15, -- Height of the floating window
            border = {"↖", "─", "┐", "│", "┘", "─", "└", "│"}, -- Border characters of the floating window
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
            preview_window_title = {
                enable = true,
                position = "left"
            } -- Whether
        })
    end
}, {
    "folke/trouble.nvim",
    lazy = false,
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        require("trouble").setup({
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        })
    end
}, {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
        require("plugins.todo-comments")
    end
}, {
    "folke/noice.nvim",
    config = function()
        require("plugins.noice")
    end,
    dependencies = { -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim", "rcarriga/nvim-notify"}
}, "ray-x/go.nvim", "ray-x/guihua.lua", {
    "catppuccin/nvim",
    as = "catppuccin"
}, { -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = { -- Automatically install LSPs to stdpath for neovim
    {
        "williamboman/mason.nvim",
        config = true
    }, "williamboman/mason-lspconfig.nvim", {
        "j-hui/fidget.nvim",
        opts = {}
    }, {"b0o/schemastore.nvim"}, {"hrsh7th/cmp-nvim-lsp"}}
}, {
    -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = { -- Snippet Engine & its associated nvim-cmp source
    "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip", -- Adds LSP completion capabilities
    "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline", -- Adds a number of user-friendly snippets
    "rafamadriz/friendly-snippets", -- Adds vscode-like pictograms
    "onsails/lspkind.nvim"},
    config = function()
        require("plugins.cmp")
    end
}, { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = function()
        pcall(require("nvim-treesitter.install").update({
            with_sync = true
        }))
    end,
    dependencies = {"nvim-treesitter/nvim-treesitter-textobjects"}
}, {
    "rcarriga/nvim-dap-ui",
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"}
}, "theHamsta/nvim-dap-virtual-text", "leoluz/nvim-dap-go", -- Git related plugins
"tpope/vim-fugitive", "lewis6991/gitsigns.nvim", "nvim-lualine/lualine.nvim", -- Fancier statusline
"stevearc/dressing.nvim", {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {}
}, {
    "numToStr/Comment.nvim", -- "gc" to comment visual regions/lines
    event = {"BufRead", "BufNewFile"},
    config = true
}, "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
-- Fuzzy Finder (files, lsp, etc)
{
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    version = false,
    lazy = true,
    dependencies = {"nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make"
    }, "nvim-telescope/telescope-ui-select.nvim" -- "nvim-telescope/telescope-frecency.nvim",
    }
}, "nvim-telescope/telescope-symbols.nvim",
-- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
                       {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    cond = vim.fn.executable("make") == 1
}, {
    "folke/twilight.nvim",
    ft = "markdown",
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    }
}, {
    "fei6409/log-highlight.nvim",
    config = function()
        require("log-highlight").setup({})
    end
}, {
    "echasnovski/mini.nvim",
    config = function()
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [']quote
        --  - ci'  - [C]hange [I]nside [']quote
        require("mini.ai").setup({
            n_lines = 500
        })

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
    config = function()
        require("nvim-surround").setup()
    end
}, -- find and replace
{
    "windwp/nvim-spectre",
    enabled = false,
    event = "BufRead",
    keys = {{
        "<leader>Rr",
        function()
            require("spectre").open()
        end,
        desc = "Replace"
    }, {
        "<leader>Rw",
        function()
            require("spectre").open_visual({
                select_word = true
            })
        end,
        desc = "Replace Word"
    }, {
        "<leader>Rf",
        function()
            require("spectre").open_file_search()
        end,
        desc = "Replace Buffer"
    }}
}, {
    "sbdchd/neoformat",
    config = function()
        -- vim.api.nvim_create_autocmd({ "BufWritePre", "TextChanged" }, {
        vim.api.nvim_create_autocmd({"BufWritePre"}, {
            pattern = {"*.json", "*.yml", "*.yaml", "*.js", "*.ts", "*.lua", "*.cpp", "*.hpp", "*.cxx", "*.hxx", "*.cc",
                       "*.c", "*.h", "*.rs", "*.py"},
            command = "Neoformat"
        })
    end
}, {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
        require("plugins.copilot")
    end
}, -- Autotags
{
    "windwp/nvim-ts-autotag",
    opts = {}
}, {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {"LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile"},
    -- optional for floating window border decoration
    dependencies = {"nvim-lua/plenary.nvim"},
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {{
        "<leader>gg",
        "<cmd>LazyGit<cr>",
        desc = "LazyGit"
    }}
}, -- showing keybindings
-- {
--     "folke/which-key.nvim",
--     event = "VeryLazy",
--     config = function()
--         require("plugins.which-key")
--     end,
--     keys = {
--         {
--             "<leader>wk",
--             function()
--                 require("which-key").show({ global = false })
--             end,
--             desc = "Buffer Local Keymaps (which-key)",
--         },
--     },
-- },
-- nvim dashboard
{
    "nvim-tree/nvim-tree.lua",
    config = function()
        require("nvim-tree").setup()
    end
}, {
    'echasnovski/mini.nvim',
    version = false
}, {
    "sainnhe/gruvbox-material",
    enabled = true,
    priority = 1000,
    config = function()
        vim.g.gruvbox_material_transparent_background = 1
        vim.g.gruvbox_material_foreground = "mix"
        vim.g.gruvbox_material_background = "hard"
        vim.g.gruvbox_material_ui_contrast = "high"
        vim.g.gruvbox_material_float_style = "bright"
        vim.g.gruvbox_material_statusline_style = "material"
        vim.g.gruvbox_material_cursor = "auto"

        -- vim.g.gruvbox_material_colors_override = { bg0 = '#16181A' } -- #0e1010
        -- vim.g.gruvbox_material_better_performance = 1

        vim.cmd.colorscheme("gruvbox-material")
    end
}, {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = {
            enabled = true
        },
        dashboard = {
            enabled = true
        },
        notifier = {
            enabled = true,
            timeout = 3000
        },
        quickfile = {
            enabled = true
        },
        statuscolumn = {
            enabled = true
        },
        words = {
            enabled = true
        },
        styles = {
            notification = {
                wo = {
                    wrap = true
                } -- Wrap notifications
            }
        }
    },
    keys = {{
        "<leader>un",
        function()
            Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications"
    }, {
        "<leader>bd",
        function()
            Snacks.bufdelete()
        end,
        desc = "Delete Buffer"
    }, {
        "<leader>gg",
        function()
            Snacks.lazygit()
        end,
        desc = "Lazygit"
    }, {
        "<leader>gb",
        function()
            Snacks.git.blame_line()
        end,
        desc = "Git Blame Line"
    }, {
        "<leader>gB",
        function()
            Snacks.gitbrowse()
        end,
        desc = "Git Browse"
    }, {
        "<leader>gf",
        function()
            Snacks.lazygit.log_file()
        end,
        desc = "Lazygit Current File History"
    }, {
        "<leader>gl",
        function()
            Snacks.lazygit.log()
        end,
        desc = "Lazygit Log (cwd)"
    }, {
        "<leader>cR",
        function()
            Snacks.rename.rename_file()
        end,
        desc = "Rename File"
    }, {
        "<c-/>",
        function()
            Snacks.terminal()
        end,
        desc = "Toggle Terminal"
    }, {
        "<c-_>",
        function()
            Snacks.terminal()
        end,
        desc = "which_key_ignore"
    }, {
        "]]",
        function()
            Snacks.words.jump(vim.v.count1)
        end,
        desc = "Next Reference",
        mode = {"n", "t"}
    }, {
        "[[",
        function()
            Snacks.words.jump(-vim.v.count1)
        end,
        desc = "Prev Reference",
        mode = {"n", "t"}
    }, {
        "<leader>N",
        desc = "Neovim News",
        function()
            Snacks.win({
                file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
                width = 0.6,
                height = 0.6,
                wo = {
                    spell = false,
                    wrap = false,
                    -- signcolumn = "yes",
                    statuscolumn = " ",
                    conceallevel = 3
                }
            })
        end
    }},
    init = function()
        Snacks = require("snacks")
        vim.api.nvim_create_autocmd("User", {
            pattern = "VeryLazy",
            callback = function()
                -- Setup some globals for debugging (lazy-loaded)
                _G.dd = function(...)
                    Snacks.debug.inspect(...)
                end
                _G.bt = function()
                    Snacks.debug.backtrace()
                end
                vim.print = _G.dd -- Override print to use snacks for `:=` command
                -- Create some toggle mappings
                Snacks.toggle.option("spell", {
                    name = "Spelling"
                }):map("<leader>us")
                Snacks.toggle.option("wrap", {
                    name = "Wrap"
                }):map("<leader>uw")
                Snacks.toggle.option("relativenumber", {
                    name = "Relative Number"
                }):map("<leader>uL")
                Snacks.toggle.diagnostics():map("<leader>ud")
                Snacks.toggle.line_number():map("<leader>ul")
                Snacks.toggle.option("conceallevel", {
                    off = 0,
                    on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2
                }):map("<leader>uc")
                Snacks.toggle.treesitter():map("<leader>uT")
                Snacks.toggle.option("background", {
                    off = "light",
                    on = "dark",
                    name = "Dark Background"
                }):map("<leader>ub")
                Snacks.toggle.inlay_hints():map("<leader>uh")
            end
        })
    end
}}}

require("lazy").setup({
    spec = plugin_specs,
    ui = {
        border = "rounded",
        title = "Plugin Manager",
        title_pos = "center"
    },
    rocks = {
        enabled = false
    }
})
