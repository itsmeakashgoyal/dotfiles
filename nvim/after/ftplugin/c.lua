-- C-specific settings
local set = vim.opt_local

-- Indentation (follows K&R style by default)
set.tabstop = 4
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true

-- Comment string for C
set.commentstring = "/* %s */"

-- Format options
set.formatoptions:remove({ "o", "r" }) -- Don't auto-insert comment leader

-- Text width for better code formatting
set.textwidth = 100
set.colorcolumn = "100"

-- Compiler settings
vim.bo.makeprg = "gcc -Wall -Wextra -std=c11 -O2 -o %:r %"

-- Keymapping for compile and run (F9)
vim.keymap.set("n", "<F9>", function()
    local filepath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t:r")
    local dirpath = vim.fn.expand("%:p:h")
    
    -- Determine compiler
    local compiler = vim.fn.executable("clang") == 1 and "clang" or "gcc"
    if vim.fn.executable(compiler) == 0 then
        vim.notify("No C compiler found!", vim.log.levels.ERROR)
        return
    end
    
    -- Create horizontal split for terminal
    vim.cmd("split")
    vim.cmd("wincmd J")
    vim.cmd("resize 15")
    
    -- Compile and run
    local compile_cmd = string.format(
        "cd %s && %s -Wall -Wextra -std=c11 -O2 %s -o %s && ./%s",
        vim.fn.shellescape(dirpath),
        compiler,
        vim.fn.shellescape(filepath),
        vim.fn.shellescape(filename),
        vim.fn.shellescape(filename)
    )
    
    vim.cmd("terminal " .. compile_cmd)
    vim.cmd("startinsert")
end, { buffer = true, silent = true, desc = "Compile and run C file" })

-- Keymapping for compile only (F8)
vim.keymap.set("n", "<F8>", function()
    vim.cmd("write")
    vim.cmd("make")
end, { buffer = true, silent = true, desc = "Compile C file" })

