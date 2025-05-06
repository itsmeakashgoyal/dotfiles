return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
        local eslint = lint.linters.eslint_d

        local pattern = [[^([^:]+):(%d+):(%d+):%s+([^:]+):%s+(.*)$]]
        local groups = { "file", "lnum", "col", "severity", "message" }
        local severity_map = {
            ["error"] = vim.diagnostic.severity.ERROR,
            ["warning"] = vim.diagnostic.severity.WARN,
            ["performance"] = vim.diagnostic.severity.WARN,
            ["style"] = vim.diagnostic.severity.INFO,
            ["information"] = vim.diagnostic.severity.INFO,
        }

        -- if Eslint error configuration not found : change MasonInstall eslint@version or npm i -g eslint at a specific version
        lint.linters_by_ft = {
            c = { "gcc" },
            cpp = { "gcc", "clang-tidy" }, -- Add C++ linters here
            javascript = { "eslint_d" },
            typescript = { "eslint_d" },
            javascriptreact = { "eslint_d" },
            typescriptreact = { "eslint_d" },
            svelte = { "eslint_d" },
            python = { "pylint" },
        }

        lint.linters.gcc = {
            cmd = "gcc",
            stdin = false, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
            append_fname = true, -- Automatically append the file name to `args` if `stdin = false` (default: true)
            args = { "-Wall", "-std=c99" }, -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
            stream = "stderr", -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
            ignore_exitcode = true, -- set this to true if the linter exits with a code != 0 and that's considered normal.
            env = nil, -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
            parser = require("lint.parser").from_pattern(pattern, groups, severity_map, { ["source"] = "gcc" }),
        }

        lint.linters["clang-tidy"] = {
            cmd = "clang-tidy",
            stdin = false,
            append_fname = true,
            args = { "--quiet" },
            stream = "stderr",
            ignore_exitcode = true,
            parser = require("lint.parser").from_pattern(
                [[([^:]+):(%d+):(%d+): (%w+): (.+)]],
                { "file", "line", "col", "severity", "message" },
                {
                    error = vim.diagnostic.severity.ERROR,
                    warning = vim.diagnostic.severity.WARN,
                    note = vim.diagnostic.severity.INFO,
                },
                { ["source"] = "clang-tidy" }
            ),
        }

        eslint.args = {
            "--no-warn-ignored",
            "--format",
            "json",
            "--stdin",
            "--stdin-filename",
            function()
                return vim.fn.expand("%:p")
            end,
        }

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        vim.keymap.set("n", "<leader>l", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })
    end,
}
