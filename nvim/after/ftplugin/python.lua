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

-- Python-specific options
vim.bo.makeprg = "python3 %"

-- Keymapping for run (F9)
vim.keymap.set("n", "<F9>", function()
    local filepath = vim.fn.expand("%:p")
    
    if vim.fn.executable("python3") == 0 then
        vim.notify("Python3 not found!", vim.log.levels.ERROR)
        return
    end
    
    -- Create horizontal split for terminal
    vim.cmd("split")
    vim.cmd("wincmd J")
    vim.cmd("resize 15")
    
    -- Run Python script
    vim.cmd("terminal python3 " .. vim.fn.shellescape(filepath))
    vim.cmd("startinsert")
end, { buffer = true, silent = true, desc = "Run Python file" })

-- Keymapping for run in ipython/python REPL (F8)
vim.keymap.set("n", "<F8>", function()
    local filepath = vim.fn.expand("%:p")
    
    -- Prefer ipython if available
    local python_repl = vim.fn.executable("ipython") == 1 and "ipython" or "python3"
    
    -- Create horizontal split for terminal
    vim.cmd("split")
    vim.cmd("wincmd J")
    vim.cmd("resize 15")
    
    -- Run in REPL
    local cmd = python_repl == "ipython" 
        and string.format("ipython -i %s", vim.fn.shellescape(filepath))
        or string.format("python3 -i %s", vim.fn.shellescape(filepath))
    
    vim.cmd("terminal " .. cmd)
    vim.cmd("startinsert")
end, { buffer = true, silent = true, desc = "Run Python file in REPL" })

-- Quick run for testing
vim.keymap.set("n", "<leader>r", function()
    vim.cmd("write")
    local output = vim.fn.system("python3 " .. vim.fn.shellescape(vim.fn.expand("%:p")))
    vim.notify(output, vim.log.levels.INFO)
end, { buffer = true, silent = true, desc = "Quick run Python file" })
