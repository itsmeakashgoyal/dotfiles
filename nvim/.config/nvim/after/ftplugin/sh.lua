-- Shell script settings (sh/bash)
local set = vim.opt_local

-- Indentation
set.tabstop = 2
set.shiftwidth = 2
set.softtabstop = 2
set.expandtab = true

-- Comment string
set.commentstring = "# %s"

-- Format options
set.formatoptions:remove({ "o", "r" }) -- Don't auto-insert comment leader
set.formatoptions:append("j") -- Remove comment leader when joining lines

-- Text width
set.textwidth = 100
set.colorcolumn = "100"

-- Keymapping for run (F9)
vim.keymap.set("n", "<F9>", function()
    local filepath = vim.fn.expand("%:p")
    
    -- Make executable if not already
    vim.fn.system("chmod +x " .. vim.fn.shellescape(filepath))
    
    -- Create horizontal split for terminal
    vim.cmd("split")
    vim.cmd("wincmd J")
    vim.cmd("resize 15")
    
    -- Run shell script
    vim.cmd("terminal bash " .. vim.fn.shellescape(filepath))
    vim.cmd("startinsert")
end, { buffer = true, silent = true, desc = "Run shell script" })

-- Keymapping for shellcheck (F8)
vim.keymap.set("n", "<F8>", function()
    if vim.fn.executable("shellcheck") == 0 then
        vim.notify("shellcheck not installed. Install it for shell script linting.", vim.log.levels.WARN)
        return
    end
    
    local filepath = vim.fn.expand("%:p")
    local output = vim.fn.system("shellcheck " .. vim.fn.shellescape(filepath))
    
    if vim.v.shell_error == 0 then
        vim.notify("✓ No shellcheck issues found!", vim.log.levels.INFO)
    else
        -- Show output in a split
        vim.cmd("split")
        vim.cmd("wincmd J")
        vim.cmd("resize 15")
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))
        vim.api.nvim_set_current_buf(buf)
        vim.bo.filetype = "shellcheck"
    end
end, { buffer = true, silent = true, desc = "Run shellcheck on script" })

-- Make file executable
vim.keymap.set("n", "<leader>x", function()
    local filepath = vim.fn.expand("%:p")
    vim.fn.system("chmod +x " .. vim.fn.shellescape(filepath))
    vim.notify("Made executable: " .. filepath, vim.log.levels.INFO)
end, { buffer = true, silent = true, desc = "Make script executable" })

