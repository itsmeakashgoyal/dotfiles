return {
    "nvim-lua/plenary.nvim", --lua functions that many plugins use
    "christoomey/vim-tmux-navigator", -- tmux & split window nav
    vim.opt.runtimepath:remove("/usr/share/vim/vimfiles"), -- separate vim plugins from neovim in case vim still in use
}
