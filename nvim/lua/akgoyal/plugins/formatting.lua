return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters = {
                clang_format = {
                    prepend_args = { "--style=file", "--fallback-style=LLVM" },
                },
                shfmt = {
                    prepend_args = { "-i", "4" },
                },
            },
            formatters_by_ft = {
                c = { "clang_format" },
                json = { "prettier" },
                yaml = { "prettier" },
                -- markdown = { "prettier" },
                graphql = { "prettier" },
                liquid = { "prettier" },
                lua = { "stylua" },
                -- Conform will run multiple formatters sequentially
                go = { "goimports", "gofmt" },
                -- You can also customize some of the format options for the filetype
                rust = { "rustfmt", lsp_format = "fallback" },
                python = { "black" },
                markdown = { "prettier" },
                ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            },
        })

        -- Configure individual formatters
        conform.formatters.prettier = {
            args = {
                "--stdin-filepath",
                "$FILENAME",
                "--tab-width",
                "4",
                "--use-tabs",
                "false",
            },
        }
        conform.formatters.shfmt = {
            prepend_args = { "-i", "4" },
        }

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = " Prettier Format whole file or range (in visual mode) with" })
    end,
}
