"
"  ▓▓▓▓▓▓▓▓▓▓
" ░▓ author ▓ Akash Goyal
" ░▓ file   ▓ nvim/.config/nvim/ginit.vim
" ░▓▓▓▓▓▓▓▓▓▓
"
" GUI-specific settings for nvim-qt and Neovide. Only loaded by GUI
" frontends, not terminal Neovim.

if exists('g:GuiLoaded')
    " ── nvim-qt ──────────────────────────────────────────
    GuiFont! JetBrainsMono\ Nerd\ Font:h11
    GuiTabline 0
    GuiPopupmenu 0
    let g:GuiWindowOpacity = 1.0

    nnoremap <silent> <F10> :call ToggleTransparency()<CR>
    nnoremap <silent> <F11> :call GuiWindowFullScreen(!g:GuiWindowFullScreen)<CR>

    function! ToggleTransparency()
        if g:GuiWindowOpacity == 1.0
            let g:GuiWindowOpacity = 0.9
        else
            let g:GuiWindowOpacity = 1.0
        endif
        call GuiWindowOpacity(g:GuiWindowOpacity)
    endfunction
endif

if exists('g:neovide')
    " ── Neovide ──────────────────────────────────────────
    set guifont=JetBrainsMono\ Nerd\ Font:h11
    let g:neovide_remember_window_size = v:true
    let g:neovide_transparency = 1.0

    nnoremap <silent> <F10> :lua vim.g.neovide_transparency = vim.g.neovide_transparency == 1.0 and 0.8 or 1.0<CR>
    nnoremap <silent> <F11> :let g:neovide_fullscreen = !g:neovide_fullscreen<CR>
endif
