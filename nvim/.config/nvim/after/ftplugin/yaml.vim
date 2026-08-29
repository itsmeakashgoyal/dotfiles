"
"  ▓▓▓▓▓▓▓▓▓▓
" ░▓ author ▓ Akash Goyal
" ░▓ file   ▓ nvim/.config/nvim/after/ftplugin/yaml.vim
" ░▓▓▓▓▓▓▓▓▓▓
"
" YAML: disable syntax highlighting on files over 500 lines (perf).
" Turn off syntax highlighting for large YAML files.
if line('$') > 500
  setlocal syntax=OFF
endif
