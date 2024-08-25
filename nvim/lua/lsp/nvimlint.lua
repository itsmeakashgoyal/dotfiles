require("lint").linters_by_ft = {
    cpp = {"clangtidy"},
    cmake = {"cmakelint"}
    --  python = {'pylint'} -- too much noise
}

vim.api.nvim_create_autocmd(
    {"InsertLeave", "BufWritePost"},
    {
        callback = function()
            require("lint").try_lint()
        end
    }
)
