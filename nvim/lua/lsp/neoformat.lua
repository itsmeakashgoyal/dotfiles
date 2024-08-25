vim.g.neoformat_c_clangformat = {
    exe = "clang-format",
    args = {"--style=file"},
    stdin = 1
}
vim.g.neoformat_enabled_c = {"clangformat"}
vim.g.neoformat_cpp_clangformat = {
    exe = "clang-format",
    args = {"--style=file"},
    stdin = 1
}
-- vim.g.neoformat_enabled_cpp = { "clangformat" }

vim.g.neoformat_enabled_python = {"black"}
