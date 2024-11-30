-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight',
                                                    {clear = true})
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function() vim.highlight.on_yank() end,
    group = highlight_group,
    pattern = '*'
})

function StyluaFormat()
    local current_dir = vim.fn.getcwd()
    local file_dir = vim.fn.fnamemodify(vim.fn.expand "%:p", ":h")
    vim.cmd("cd " .. file_dir)
    vim.cmd("silent! !stylua --search-parent-directories " ..
                vim.fn.expand "%:p")
    vim.cmd("cd " .. current_dir)
end
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.lua",
    callback = function() StyluaFormat() end,
    desc = "Auto-format Lua files with Stylua"
})
