#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/16-iterm.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# iTerm2 shell integration (macOS only). Installed to ~/.iterm2_shell_integration.zsh
# by scripts/setup/iterm.sh, copied straight from the running iTerm2.app bundle so it
# always matches the installed version - not tracked in git, regenerated per machine.
#
# Enables: command status marks in the scrollbar, jump-to-previous-prompt
# (Cmd+Shift+Up/Down), per-directory/host badges, "Show Recent Directories",
# and download/upload over SSH (it2dl/it2ul). Its precmd/preexec hooks only
# print OSC escape sequences - no subprocess calls - so this doesn't reintroduce
# the per-prompt latency the Starship git_status fix just addressed.

if [[ "$TERM_PROGRAM" == "iTerm.app" && -f "$HOME/.iterm2_shell_integration.zsh" ]]; then
    source "$HOME/.iterm2_shell_integration.zsh"
fi
