return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        config = function()
            -- import nvim-treesitter plugin
            local treesitter = require("nvim-treesitter.configs")

            -- configure treesitter
            treesitter.setup({ -- enable syntax highlighting
                highlight = {
                    enable = true,
                },
                -- enable indentation
                indent = { enable = true },

                -- ensure these languages parsers are installed
                ensure_installed = {
                    "c",           -- C language
                    "cpp",         -- C++ language
                    "python",      -- Python language
                    "make",        -- Makefile
                    "cmake",       -- CMake
                    "bash",        -- Shell scripts
                    "lua",         -- Neovim config
                    "vim",         -- Vim config
                    "vimdoc",      -- Vim documentation
                    "markdown",    -- Documentation
                    "markdown_inline",
                    "git_config",  -- Git configuration
                    "git_rebase",  -- Git rebase
                    "gitcommit",   -- Git commits
                    "gitignore",   -- Git ignore
                    "diff",        -- Diffs
                    "json",        -- JSON files
                    "yaml",        -- YAML files
                    "toml",        -- TOML files (Python configs)
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                    },
                },
                additional_vim_regex_highlighting = false,
            })
        end,
    },
}
