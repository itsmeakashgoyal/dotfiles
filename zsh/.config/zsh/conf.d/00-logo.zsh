#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/00-logo.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# ASCII art greeting on interactive shell startup.
# Set DOTFILES_NO_LOGO=1 to disable.

# Guards: only in interactive, non-tmux sessions
[[ -o interactive ]] || return 0
[[ -n "$TMUX" ]] && return 0
[[ -n "$DOTFILES_NO_LOGO" ]] && return 0

local _rand=$(( RANDOM % 2 + 1 ))
case $_rand in
    1)
cat << 'X0'
[36m  _ ___  ______ _ ______   _ _______  _ _______
 _\\\  \/     [34m/[36m_\\\  _  [34m/[36m_ _\\\_     [34m\[36m_\\\  _   [34m\
 [34m\    _/     /      \_/  \    [36m/   [34m__/      [34m/    [34m\
[37m /    \      [34m\__          \   [37m\     [34m\__   /     [32m/
[37m/[31m_____[37m/\       [32m/[31m__________[37m/[31m____[37m\      [32m/[31m________[32m/
[37m        \[31m_____[32m/                 [37m\[31m____[32m/[0m
X0
    ;;
    2)
cat << 'X0'
[36m___/[37m\[36m  _____ /[37m\[36m______[0;36m  ____/[37m\[0;36m    ___/[37m\
[36m\[0;36m [33m_[0;36m  [37m\/[36m  [33m.:[37m/[36m/[33m.:[0m\[36m____[37m/[36m/[33m_[0m\[36m_[33m.[0;36m  [37m\/[36m [33m.[36m/[0;36m__ [37m\
[0;36m \[33m\[0;36m  /    [37m/[36m/    ___[37m/[36m/  [33m.[0m\[36m/ _[37m/[36m/ \  [37m/[0;36m  [37m\
[36m /[33m.:[0;36m \    \[33m_.[0;36m     [37m/[36m/    _[33m. [37m\/[36m [33m.:[0;36m\/   [37m/
[36m/[34m____[0m/[36m\  [34m__[0;36m\[34m/[34m__[0;36m  [37m/[36m/[34m______[0;36m| [37m/[36m\[34m_______[0m/
[36m       \/      \/        |/[0m
X0
    ;;
esac
