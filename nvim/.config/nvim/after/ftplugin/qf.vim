"
"  ▓▓▓▓▓▓▓▓▓▓
" ░▓ author ▓ Akash Goyal
" ░▓ file   ▓ nvim/.config/nvim/after/ftplugin/qf.vim
" ░▓▓▓▓▓▓▓▓▓▓
"
" Quickfix: auto-size the window to fit its contents (5-15 lines).
" Set quickfix window height, see also https://github.com/lervag/vimtex/issues/1127
function! AdjustWindowHeight(minheight, maxheight)
  execute max([a:minheight, min([line('$'), a:maxheight])]) . 'wincmd _'
endfunction

call AdjustWindowHeight(5, 15)
