--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/lua/akgoyal/lazy.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Bootstraps lazy.nvim and loads every plugin spec under plugins/ and
-- plugins/lsp/.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { import = "akgoyal.plugins" },
    { import = "akgoyal.plugins.lsp" },
}, {
    checker = {
        -- Disabled (lazy.nvim's own default is also false - this repo had
        -- opted in). On session start/first-run-past-frequency, the checker
        -- fires an async git-fetch against every installed plugin's remote;
        -- if the network is slow that fetch job can still be running when
        -- you quit, and Neovim's process teardown waits on it, which is
        -- what made `nvim <any file>` -> `:q` take 10+ seconds with near-zero
        -- CPU (confirmed via `time nvim --clean` ~2s vs `time nvim` ~16s on
        -- the same trivial file - the gap disappears once plugins aren't
        -- loaded at all). Run `:Lazy check` / `:Lazy update` manually instead.
        enabled = false,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
})
