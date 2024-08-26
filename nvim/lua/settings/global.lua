local set = vim.opt
local vcmd = vim.cmd

vcmd "syntax on"
vcmd "set termguicolors"
vcmd "syntax enable"
vcmd "filetype on"
vcmd "filetype plugin indent on"
vcmd "set clipboard^=unnamed,unnamedplus"
vcmd "set winbar=%=%m%F"
vcmd "set completefunc=emoji#complete"
vcmd "set wildignore+=*/tmp/*,*.so,*.swp,*.zip"
vcmd "set backspace=indent,eol,start"
vcmd "set jumpoptions=view"
vcmd "set sessionoptions+=tabpages,globals"

-- Disable mouse mode
-- set.mouse = ''

-- Treesitter folding
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.wo.foldenable = false
vcmd "setlocal nofoldenable"
vim.api.nvim_set_option("updatetime", 300)

if vim.g.scroll_fix_enabled == nil then
    vim.g.scroll_fix_enabled = false -- Start with scroll fix disabled
end

-- Remap for dealing with word wrap
set.gp = "git grep -n"
set.completeopt = {"menuone", "noselect", "noinsert"}
set.shortmess =
    set.shortmess +
    {
        c = true
    }
set.background = "dark"
set.ignorecase = true -- ignore case in search
set.infercase = true -- adjust case in search
set.smartcase = true -- do not ignore case with capitals
set.scrolloff = 8
set.hlsearch = true
set.updatetime = 300
set.splitright = true -- put new splits to the right
set.splitbelow = true -- put new splits below
set.lazyredraw = true -- do not redraw for macros, faster execution
set.undofile = true -- persistent undo even after session close
set.spellfile = vim.fn.stdpath "config" .. "/spell/en.utf-8.add"
set.formatoptions:remove {"o"}

set.number = true -- Precede each line with its line number
set.encoding = "utf-8"
set.cursorline = true

set.expandtab = true -- Use the appropriate number of spaces to insert a Tab
set.shiftwidth = 4 -- Number of spaces to use for each step of indent
set.tabstop = 4 -- Number of visual <Space> per <Tab>
set.softtabstop = 4 -- Number of spaces per tab wwhile performing editing operations
set.autoindent = true -- Copy indent from current line when staring a new line
set.relativenumber = true -- Show the line number relative to the current line
set.incsearch = true
set.inccommand = "split" -- preview of replacement operations
set.laststatus = 2
set.cmdheight = 1
set.ruler = true -- Show the line and column number of cursor position
set.smarttab = true -- Insert blanks according to shiftwidth, or tabstop in front of lines

-- Disable copilot on boot
vim.b.copilot_enabled = false

vim.cmd "command! GetCurrentFileDir lua print_current_file_dir()"

-- Key mappings
vim.cmd "command! Fold lua _G.toggle_function_folding()"

vim.api.nvim_set_keymap(
    "n",
    "fld",
    [[<Cmd>lua _G.toggle_function_folding()<CR>]],
    {
        noremap = true,
        silent = false
    }
)
vim.cmd [[
  command! -range=% -nargs=* -complete=customlist,v:lua.my_custom_complete ProcessTasks :lua _G.process_task_list(<line1>, <line2>, <f-args>)
]]