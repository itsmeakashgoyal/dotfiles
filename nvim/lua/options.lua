vim.g.mapleader = " "                                   -- change leader to a space
vim.g.maplocalleader = " "                              -- change localleader to a space

vim.g.loaded_netrw = 1                                  -- disable netrw
vim.g.loaded_netrwPlugin = 1  

local options = {
    backup = false,                          -- creates a backup file
    clipboard = "unnamedplus",               -- allows neovim to access the system clipboard
    cmdheight = 2,                           -- more space in the neovim command line for displaying messages
    completeopt = { "menuone", "noselect", "noinsert" }, -- mostly just for cmp
    conceallevel = 0,                        -- so that `` is visible in markdown files
    encoding = "utf-8",
    fileencoding = "utf-8",                  -- the encoding written to a file
    hlsearch = true,                         -- highlight all matches on previous search pattern
    ignorecase = true,                       -- ignore case in search patterns
    mouse = "",                              -- allow the mouse to be used in neovim or '' to use copy
    pumheight = 10,                          -- pop up menu height
    showmode = false,                        -- we don't need to see things like -- INSERT -- anymore
    showtabline = 1,                         -- always show tabs
    smartcase = true,                        -- smart case
    smartindent = true,                      -- make indenting smarter again
    splitbelow = true,                       -- force all horizontal splits to go below current window
    splitright = true,                       -- force all vertical splits to go to the right of current window
    swapfile = false,                        -- creates a swapfile
    termguicolors = true,                    -- set term gui colors (most terminals support this)
    timeoutlen = 300,                        -- time to wait for a mapped sequence to complete (in milliseconds)
    undofile = true,                         -- enable persistent undo
    updatetime = 300,                        -- faster completion (4000ms default)
    writebackup = false,                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
    expandtab = true,                        -- convert tabs to spaces
    shiftwidth = 4,                          -- the number of spaces inserted for each indentation
    tabstop = 4,                             -- insert 4 spaces for a tab
    softtabstop = 4,                         -- Number of spaces per tab while performing editing operations
    cursorline = true,                       -- highlight the current line
    number = true,                           -- set numbered lines
    relativenumber = true,                   -- set relative numbered lines
    numberwidth = 4,                         -- set number column width to 2 {default 4}

    signcolumn = "yes",                      -- always show the sign column, otherwise it would shift the text each time
    wrap = true,                             -- display lines as one long line
    linebreak = true,                        -- companion to wrap, don't split words
    scrolloff = 8,                           -- minimal number of screen lines to keep above and below the cursor
    sidescrolloff = 8,                       -- minimal number of screen columns either side of cursor if wrap is `false`
    guifont = "monospace:h17",               -- the font used in graphical neovim applications
    whichwrap = "bs<>[]hl",                  -- which "horizontal" keys are allowed to travel to prev/next line
    gp = "git grep -n",                      -- Remap for dealing with word wrap
    background = "dark",
    infercase = true,                        -- adjust case in search    
    lazyredraw = false,                      -- do not redraw for macros, faster execution
    spellfile = vim.fn.stdpath "config" .. "/spell/en.utf-8.add",
    autoindent = true,                       -- Copy indent from current line when staring a new line
    incsearch = true,
    inccommand = "split",                    -- preview of replacement operations
    laststatus = 2,
    ruler = true,                            -- Show the line and column number of cursor position
    smarttab = true,                         -- Insert blanks according to shiftwidth, or tabstop in front of lines
    -- Unprintable chars mapping
    -- {tab = "••"|">~",eol = "↴"|"¶"|"$", nbsp = "␣"|"%", space = "_" }
    listchars = { tab = [[→→]], trail = "•", extends = "»", precedes = "«" }
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- vim.opt.shortmess = "ilmnrx"                        -- flags to shorten vim messages, see :help 'shortmess'
vim.opt.shortmess:append "c"                           -- don't give |ins-completion-menu| messages
vim.opt.iskeyword:append "-"                           -- hyphenated words recognized by searches
vim.opt.formatoptions:remove({ "c", "r", "o" })        -- don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode.
vim.opt.runtimepath:remove("/usr/share/vim/vimfiles")  -- separate vim plugins from neovim in case vim still in use

vim.cmd([[
    syntax on
    set termguicolors
    syntax enable
    filetype on
    filetype plugin indent on
    set clipboard^=unnamed,unnamedplus
    set winbar=%=%m%F
    set completefunc=emoji#complete
    set wildignore+=*/tmp/*,*.so,*.swp,*.zip
    set backspace=indent,eol,start
    set jumpoptions=view
    set sessionoptions+=tabpages,globals
]])

-- Treesitter folding
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.wo.foldenable = false
vim.cmd("setlocal nofoldenable")

if vim.g.scroll_fix_enabled == nil then
    vim.g.scroll_fix_enabled = false -- Start with scroll fix disabled
end

-- Disable copilot on boot
vim.b.copilot_enabled = false

-- Set colorscheme
-- vim.cmd [[colorscheme onedark]]
vim.cmd.colorscheme "catppuccin"
