--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/after/ftplugin/python.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Python: PEP 8 indentation (4-space), 88-col width (Black's default),
-- run/REPL/quick-run keymaps (F9/F8/<leader>r).
-- Python-specific settings
local set = vim.opt_local

-- Indentation (PEP 8 style)
set.tabstop = 4
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true

-- Comment string
set.commentstring = "# %s"

-- Format options
set.formatoptions:remove({ "o", "r" }) -- Don't auto-insert comment leader
set.formatoptions:append("j") -- Remove comment leader when joining lines

-- Text width (PEP 8 recommends 79, but 88 is Black's default)
set.textwidth = 88
set.colorcolumn = "88"

-- Show whitespace errors (trailing spaces, tabs)
set.list = true

-- Python binary: prefer python3, but fall back to python (Windows' Scoop
-- package installs it as "python", not "python3" - see
-- scripts/setup/windows.ps1's own verify step for the same fallback).
local python_bin = vim.fn.executable("python3") == 1 and "python3" or "python"

-- Python-specific options
vim.bo.makeprg = python_bin .. " %"

-- Keymapping for run (F9)
vim.keymap.set("n", "<F9>", function()
    local filepath = vim.fn.expand("%:p")

    if vim.fn.executable(python_bin) == 0 then
        vim.notify("Python not found!", vim.log.levels.ERROR)
        return
    end

    -- Create horizontal split for terminal
    vim.cmd("split")
    vim.cmd("wincmd J")
    vim.cmd("resize 15")

    -- Run Python script
    vim.cmd("terminal " .. python_bin .. " " .. vim.fn.shellescape(filepath))
    vim.cmd("startinsert")
end, { buffer = true, silent = true, desc = "Run Python file" })

-- Keymapping for run in ipython/python REPL (F8)
vim.keymap.set("n", "<F8>", function()
    local filepath = vim.fn.expand("%:p")

    -- Prefer ipython if available
    local python_repl = vim.fn.executable("ipython") == 1 and "ipython" or python_bin

    -- Create horizontal split for terminal
    vim.cmd("split")
    vim.cmd("wincmd J")
    vim.cmd("resize 15")

    -- Run in REPL
    local cmd = python_repl == "ipython"
        and string.format("ipython -i %s", vim.fn.shellescape(filepath))
        or string.format("%s -i %s", python_bin, vim.fn.shellescape(filepath))

    vim.cmd("terminal " .. cmd)
    vim.cmd("startinsert")
end, { buffer = true, silent = true, desc = "Run Python file in REPL" })

-- Quick run for testing
vim.keymap.set("n", "<leader>r", function()
    vim.cmd("write")
    local output = vim.fn.system(python_bin .. " " .. vim.fn.shellescape(vim.fn.expand("%:p")))
    vim.notify(output, vim.log.levels.INFO)
end, { buffer = true, silent = true, desc = "Quick run Python file" })
