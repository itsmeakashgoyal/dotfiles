#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/17-bookmarks.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Named directory bookmarks (zsh-native, no plugin). `hash -d name=path` makes
# ~name expand to that path everywhere: `cd ~df`, `ls ~cfg/zsh`, `nvim ~df/...`,
# and zsh abbreviates matching paths back to ~name in the prompt/tab-completion.
#
# This complements zoxide: zoxide jumps by frecency ("z proj"); these are stable,
# explicit shortcuts you name yourself. Machine-specific bookmarks belong in
# 99-private.zsh (sourced later) using the same `hash -d name=path` syntax.

# name → path. Only registered if the target directory actually exists, so an
# absent dir on a given machine doesn't create a dangling ~name.
typeset -A _dotfiles_bookmarks=(
    df    "$HOME/dotfiles"
    cfg   "$HOME/.config"
    zdot  "${ZDOTDIR:-$HOME/.config/zsh}"
    dl    "$HOME/Downloads"
    dev   "$HOME/ws"
    ltb   "$HOME/linuxtoolbox"
)

for _name in "${(k)_dotfiles_bookmarks[@]}"; do
    [[ -d "${_dotfiles_bookmarks[$_name]}" ]] && hash -d "$_name=${_dotfiles_bookmarks[$_name]}"
done
unset _name
unset _dotfiles_bookmarks
