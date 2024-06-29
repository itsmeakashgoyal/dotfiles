return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      clangd = function(_, opts)
        opts.capabilities.offsetEncoding = { "utf-16" }
      end,
    },
  },
  autoformat = false,

  { "folke/flash.nvim", enabled = false },
  { "echasnovski/mini.pairs", enabled = false },
  --{
  --"LazyVim/LazyVim",
  --opts = {
  --colorscheme = "catppuccin",
  --},
  --},

  --{
  --"catppuccin/nvim",
  --opts = { style = "frappe" },
  --},
}
