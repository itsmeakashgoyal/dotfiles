"
"  ▓▓▓▓▓▓▓▓▓▓
" ░▓ author ▓ Akash Goyal
" ░▓ file   ▓ nvim/.config/nvim/after/ftplugin/lua.vim
" ░▓▓▓▓▓▓▓▓▓▓
"
" Lua: disable auto-comment continuation, F9 sources the current file.

" Disable inserting comment leader after hitting o or O or <Enter>
set formatoptions-=o
set formatoptions-=r

nnoremap <buffer><silent> <F9> :luafile %<CR>
