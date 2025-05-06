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
        local cmp_nvim_lsp = require("cmp_nvim_lsp") -- import cmp-nvim-lsp plugin
        local capabilities = cmp_nvim_lsp.default_capabilities() -- used to enable autocompletion (assign to every lsp server config)

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
                "lua_ls",
                "clangd",
                "clang-format",
                "codelldb",
                "rust_analyzer",
                "pyright",
                "gopls",
            },
            -- auto install configured servers (with lspconfig)
            automatic_installation = true,
        })

        mason_tool_installer.setup({
            ensure_installed = {
                "prettier", -- prettier formatter
                "stylua", -- lua formatter
                "isort", -- python formatter
                "pylint",
                "clangd",
                { "eslint_d", version = "13.1.2" },
            },
        })

        -- NOTE: Moved from lspconfig.lua

        mason_lspconfig.setup_handlers({
            -- default handler for installed servers
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                })
            end,
            ["lua_ls"] = function()
                -- configure lua server (with special settings)
                lspconfig["lua_ls"].setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            -- make the language server recognize "vim" global
                            diagnostics = {
                                globals = { "vim" },
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                            workspace = {
                                -- make language server aware of run time files
                                library = {
                                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                                    [vim.fn.stdpath("config") .. "/lua"] = true,
                                },
                            },
                        },
                    },
                })
            end,
            ["clangd"] = function()
                lspconfig.clangd.setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                    cmd = { "clangd", "--offset-encoding=utf-16" },
                    filetypes = { "c", "cpp", "hpp", "h", "objc", "objcpp", "cuda", "proto" },
                    flags = {
                        debounce_text_changes = 500,
                    },
                    settings = {
                        ["clangd"] = {
                            ["compilationDatabasePath"] = "build",
                            ["fallbackFlags"] = { "-std=c++17" },
                        },
                    },
                    single_file_support = true,
                })
            end,
            -- ["vim-language-server"] = function()
            --     lspconfig.vimls.setup({
            --         on_attach = on_attach,
            --         flags = {
            --             debounce_text_changes = 500
            --         },
            --         capabilities = capabilities
            --     })
            -- end,
            -- ["bash-language-server"] = function()
            --     lspconfig.bashls.setup({
            --         on_attach = on_attach,
            --         capabilities = capabilities
            --     })
            -- end,
            ["pylsp"] = function()
                lspconfig.pylsp.setup({
                    on_attach = on_attach,
                    settings = {
                        pylsp = {
                            plugins = {
                                -- formatter options
                                black = {
                                    enabled = true,
                                },
                                autopep8 = {
                                    enabled = false,
                                },
                                yapf = {
                                    enabled = false,
                                },
                                -- linter options
                                pylint = {
                                    enabled = true,
                                    executable = "pylint",
                                },
                                ruff = {
                                    enabled = false,
                                },
                                pyflakes = {
                                    enabled = false,
                                },
                                pycodestyle = {
                                    enabled = false,
                                },
                                -- type checker
                                pylsp_mypy = {
                                    enabled = true,
                                    overrides = { "--python-executable", py_path, true },
                                    report_progress = true,
                                    live_mode = false,
                                },
                                -- auto-completion options
                                jedi_completion = {
                                    fuzzy = true,
                                },
                                -- import sorting
                                isort = {
                                    enabled = true,
                                },
                            },
                        },
                    },
                    flags = {
                        debounce_text_changes = 200,
                    },
                    capabilities = capabilities,
                })
            end,
            ["gopls"] = function()
                lspconfig.gopls.setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                    settings = {
                        gopls = {
                            analyses = {
                                unusedparams = true,
                                unreachable = true,
                            },
                            staticcheck = true,
                        },
                    },
                })
            end,
            ["pyright"] = function()
                lspconfig.pyright.setup({
                    on_attach = on_attach,
                    capabilities = capabilities,
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "basic",
                            },
                        },
                    },
                })
            end,
        })
    end,
}
