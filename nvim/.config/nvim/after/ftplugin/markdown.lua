--
--  ▓▓▓▓▓▓▓▓▓▓
-- ░▓ author ▓ Akash Goyal
-- ░▓ file   ▓ nvim/.config/nvim/after/ftplugin/markdown.lua
-- ░▓▓▓▓▓▓▓▓▓▓
--
-- Markdown: wrap at 80 columns, spell-check on, custom heading highlight
-- colors (h1-h6).
local set = vim.opt_local

set.textwidth = 80 -- Wrap text at 80 characters
set.spell = true -- Enable spell checking
set.linebreak = true

-- added extra highlights for markdown files to render highlights properly
-- thx to Linkarzu. Gruvbox accents (bright in dark mode, faded in light mode).

local dark = vim.o.background ~= "light"
local color1_bg = dark and "#fb4934" or "#9d0006" -- red
local color2_bg = dark and "#8ec07c" or "#427b58" -- aqua
local color3_bg = dark and "#83a598" or "#076678" -- blue
local color4_bg = dark and "#fe8019" or "#af3a03" -- orange
local color5_bg = dark and "#d3869b" or "#8f3f71" -- purple
local color6_bg = dark and "#fabd2f" or "#b57614" -- yellow
local color_fg = dark and "#282828" or "#fbf1c7"

vim.cmd(
    string.format([[highlight @markup.heading.1.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color1_bg)
)
vim.cmd(
    string.format([[highlight @markup.heading.2.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color2_bg)
)
vim.cmd(
    string.format([[highlight @markup.heading.3.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color3_bg)
)
vim.cmd(
    string.format([[highlight @markup.heading.4.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color4_bg)
)
vim.cmd(
    string.format([[highlight @markup.heading.5.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color5_bg)
)
vim.cmd(
    string.format([[highlight @markup.heading.6.markdown cterm=bold gui=bold guifg=%s guibg=%s]], color_fg, color6_bg)
)
