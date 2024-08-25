-- LSP and LS Installer
local lspconfig = require "lspconfig"
local def = require "lsp.default-lsp"
lspconfig.lua_ls.setup {
    capabilities = def.capabilities,
    on_attach = def.on_attach,
    -- signatureHelp = { enable = true },

    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = "LuaJIT"
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = {"vim", "require"}
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true)
                -- the following does not show nvim api completion
                -- library = vim.env.runtime,
            },
            hint = {
                enable = true
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false
            }
        }
    }
}

-- LSP servers installed with MASON setup from NVIM-LSPCONFIG  --------------
-- server configurations can be found here:
--    https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

-- Clangd
lspconfig.clangd.setup {
    on_attach = def.on_attach,
    capabilities = def.capabilities,
    cmd = {"clangd", "--offset-encoding=utf-16"},
    filetypes = {"c", "cpp", "hpp", "h", "objc", "objcpp", "cuda", "proto"},
    root_dir = lspconfig.util.root_pattern(
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "configure.ac",
        ".git"
    ),
    settings = {
        ["clangd"] = {
            ["compilationDatabasePath"] = "build",
            ["fallbackFlags"] = {"-std=c++17"}
        }
    },
    single_file_support = true
}

lspconfig.pyright.setup {
    filetypes = {"python", "py"}
}
lspconfig.cmake.setup {}

require("lspconfig").marksman.setup {}

local configs = require "lspconfig.configs"
-- Check if it's already defined for when reloading this file.
configs.up = {
    default_config = {
        cmd = {"up", "xpls", "serve", "--verbose"},
        filetypes = {"yaml"},
        root_dir = lspconfig.util.root_pattern "crossplane.yaml"
    }
}

require("lspconfig")["up"].setup {
    cmd = {"up", "xpls", "serve", "--verbose"},
    filetypes = {"yaml"},
    root_dir = lspconfig.util.root_pattern "crossplane.yaml",
    on_attach = def.on_attach
}

require("lspconfig").bashls.setup {
    filetypes = {"sh", "zsh"}
}

require("ionide").setup {
    on_attach = def.on_attach,
    capabilities = def.capabilities
}

-- PROJECT: lsp_lines
-- When using lsp_lines, this needs to be disabled
vim.diagnostic.config {
    virtual_text = true
}

lspconfig.gopls.setup {
    cmd = {"gopls"},
    -- for postfix snippets and analyzers
    capabilities = def.capabilities,
    settings = {
        gopls = {
            experimentalPostfixCompletions = true,
            analyses = {
                unusedparams = true,
                shadow = true
            },
            staticcheck = true,
            hints = {
                enabled = true,
                rangeVariableTypes = true,
                prameterNames = true,
                functionTypeParameters = true,
                constantValues = true,
                compositeLiteralTypes = true,
                compositeLiteralFields = true,
                assignVariableTypes = true
            }
        }
    },
    on_attach = def.on_attach
}

-- Json/Jsonc
lspconfig.jsonls.setup {
    capabilities = def.capabilities
}

-- Bash
lspconfig.bashls.setup {
    capabilities = def.capabilities
}
