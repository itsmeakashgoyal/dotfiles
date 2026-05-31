#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/10-atuin.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
# Atuin — magical shell history
# https://github.com/atuinsh/atuin
#
# Loads after 09-television.zsh so atuin takes Ctrl+R (history search)
# while television keeps Ctrl+T (file search).

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi
