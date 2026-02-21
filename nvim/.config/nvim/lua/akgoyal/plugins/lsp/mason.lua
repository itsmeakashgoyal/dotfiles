return {
    "williamboman/mason.nvim",
    lazy = false,
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "neovim/nvim-lspconfig",
        -- "saghen/blink.cmp",
    },
    config = function()
        -- import mason and mason_lspconfig
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local mason_tool_installer = require("mason-tool-installer")

        -- NOTE: Moved from lspconfig.lua
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- enable mason and configure icons
        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        mason_lspconfig.setup({
            -- servers for mason to install
            ensure_installed = {
                "clangd", -- C/C++ language server
                "pyright", -- Python language server
                "bashls", -- Bash/Shell language server
                "lua_ls", -- Lua language server (for neovim config)
            },
            -- auto install configured servers (with lspconfig)
            automatic_installation = true,
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "clang-format", -- C/C++ formatter
                "codelldb", -- C/C++ debugger
                "black", -- Python formatter
                "isort", -- Python import sorter
                "pylint", -- Python linter
                "shfmt", -- Shell formatter
                "shellcheck", -- Shell linter
                "stylua", -- Lua formatter
            },
        })

        -- Configure LSP servers directly (compatible with all mason-lspconfig versions)
        
        -- Lua Language Server (with Neovim-specific settings)
        lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                    completion = {
                        callSnippet = "Replace",
                    },
                    workspace = {
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                },
            },
        })

        -- Clangd (C/C++)
        lspconfig.clangd.setup({
            capabilities = capabilities,
            cmd = { "clangd", "--offset-encoding=utf-16" },
            filetypes = { "c", "cpp", "hpp", "h", "objc", "objcpp", "cuda" },
            settings = {
                clangd = {
                    compilationDatabasePath = "build",
                    fallbackFlags = { "-std=c++17" },
                },
            },
            single_file_support = true,
        })

        -- Pyright (Python)
        lspconfig.pyright.setup({
            capabilities = capabilities,
            settings = {
                python = {
                    analysis = {
                        typeCheckingMode = "basic",
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "workspace",
                    },
                },
            },
        })

        -- Bash Language Server
        lspconfig.bashls.setup({
            capabilities = capabilities,
            filetypes = { "sh", "bash", "zsh" },
        })
    end,
}
