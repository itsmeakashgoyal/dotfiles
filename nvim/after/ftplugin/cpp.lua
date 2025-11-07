-- C++ specific settings (modernized from cpp.vim)
local set = vim.opt_local

-- Indentation
set.tabstop = 4
set.shiftwidth = 4
set.softtabstop = 4
set.expandtab = true

-- Comment string for C++
set.commentstring = "// %s"

-- Format options
set.formatoptions:remove({ "o", "r" }) -- Don't auto-insert comment leader

-- Text width for better code formatting
set.textwidth = 100
set.colorcolumn = "100"

-- Compiler settings
vim.bo.makeprg = "g++ -Wall -Wextra -std=c++17 -O2 -o %:r %"

-- Keymapping for compile and run (F9)
vim.keymap.set("n", "<F9>", function()
    local filepath = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t:r")
    local dirpath = vim.fn.expand("%:p:h")
    
    -- Determine compiler
    local compiler = vim.fn.executable("clang++") == 1 and "clang++" or "g++"
    if vim.fn.executable(compiler) == 0 then
        vim.notify("No C++ compiler found!", vim.log.levels.ERROR)
        return
    end
    
    -- Create horizontal split for terminal
    vim.cmd("split")
    vim.cmd("wincmd J")
    vim.cmd("resize 15")
    
    -- Compile and run
    local compile_cmd = string.format(
        "cd %s && %s -Wall -Wextra -std=c++17 -O2 %s -o %s && ./%s",
        vim.fn.shellescape(dirpath),
        compiler,
        vim.fn.shellescape(filepath),
        vim.fn.shellescape(filename),
        vim.fn.shellescape(filename)
    )
    
    vim.cmd("terminal " .. compile_cmd)
    vim.cmd("startinsert")
end, { buffer = true, silent = true, desc = "Compile and run C++ file" })

-- Keymapping for compile only (F8)
vim.keymap.set("n", "<F8>", function()
    vim.cmd("write")
    vim.cmd("make")
end, { buffer = true, silent = true, desc = "Compile C++ file" })

-- Header/source switching (common in C++ development)
vim.keymap.set("n", "<leader>h", function()
    local ext = vim.fn.expand("%:e")
    local base = vim.fn.expand("%:r")
    
    local header_exts = { "h", "hpp", "hxx", "hh" }
    local source_exts = { "cpp", "cc", "cxx", "c" }
    
    local target_exts = vim.tbl_contains(header_exts, ext) and source_exts or header_exts
    
    for _, target_ext in ipairs(target_exts) do
        local target = base .. "." .. target_ext
        if vim.fn.filereadable(target) == 1 then
            vim.cmd("edit " .. target)
            return
        end
    end
    
    vim.notify("No corresponding header/source file found", vim.log.levels.WARN)
end, { buffer = true, silent = true, desc = "Switch between header and source" })

