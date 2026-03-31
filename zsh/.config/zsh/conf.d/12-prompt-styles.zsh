#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/12-prompt-styles.zsh
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
# Pure ZSH prompt styles (no framework needed).
# Adapted from xero's dotfiles (https://github.com/xero/dotfiles)
#
# These work as an alternative to Powerlevel10k. To use them:
#   1. Disable p10k in .zshrc (comment out sections 1, 5 p10k source, and 6f theme)
#   2. Run: prompt_style <name>
#
# Available styles: minimal, classic, dual, ascii, arrows, ninja
#
# Usage:
#   prompt_style minimal   # activate minimal prompt
#   prompt_style ninja     # activate ninja prompt
#
# This file only DEFINES the function — it does NOT activate any style.
# Your current prompt (p10k/starship/etc.) remains untouched until you call it.

# ---------------------------------------------------------------------------
# Git status helper for prompt
# ---------------------------------------------------------------------------
_prompt_git() {
    local test ref dirty stat

    test=$(git rev-parse --is-inside-work-tree 2>/dev/null)
    if [[ -z "$test" ]]; then
        case "$PROMPT_STYLE" in
            ascii)  echo "$reset_color%F{cyan}▒░" ;;
            arrows) echo "$reset_color%F{cyan}" ;;
        esac
        return
    fi

    ref=$(git name-rev --name-only HEAD 2>/dev/null | sed 's!remotes/!!;s!undefined!merging!')
    dirty=""
    [[ -n "$(git diff --shortstat 2>/dev/null | tail -n1)" ]] && dirty="󱐋"

    stat=""
    local status_line
    status_line=$(git status | sed -n 2p)
    case "$status_line" in
        *ahead*)     stat="⇡" ;;
        *behind*)    stat="⇣" ;;
        *diverged*)  stat="↕" ;;
        *conflicted*) stat="" ;;
    esac

    case "$PROMPT_STYLE" in
        ninja)
            echo "%F{white}$ref$dirty$stat"
            ;;
        minimal)
            echo "%F{green}$ref$dirty$stat "
            ;;
        ascii)
            echo "%{$bg[magenta]%}%F{cyan}▓▒░ %F{black}${ref}${dirty}${stat} $reset_color%F{magenta}▒░"
            ;;
        arrows)
            echo "%{$bg[magenta]%}%F{cyan} %F{black}${ref}${dirty}${stat} $reset_color%F{magenta}"
            ;;
        *)
            echo "${_PS_LVL}${_PS_LINE}[%F{white}${ref}${dirty}${stat}${_PS_LVL}]"
            ;;
    esac
}

# ---------------------------------------------------------------------------
# prompt_style — switch between pure ZSH prompt styles
# ---------------------------------------------------------------------------
prompt_style() {
    local style="${1:-minimal}"
    PROMPT_STYLE="$style"

    # allow functions in the prompt
    setopt PROMPT_SUBST
    autoload -Uz colors && colors

    # icons
    local I_CMD="❯" I_VI="❮"
    local P_CMD="─" P_VI="┈"

    # permission-based color
    local COLOR_ROOT="%F{red}"
    local COLOR_USER="%F{cyan}"
    local COLOR_NORMAL="%F{white}"
    [[ "$EUID" -ne "0" ]] && _PS_LVL="$COLOR_USER" || _PS_LVL="$COLOR_ROOT"
    _PS_LINE="${P_CMD}${P_CMD} ${P_CMD}"

    # vi-mode indicator
    _PS_MODE="$I_CMD"
    function zle-keymap-select {
        _PS_MODE="${${KEYMAP/vicmd/${I_VI}}/(main|viins)/${I_CMD}}"
        local p_s="${${KEYMAP/vicmd/${P_VI}}/(main|viins)/${P_CMD}}"
        _PS_LINE="${p_s}${p_s} ${p_s}"
        zle reset-prompt
    }
    zle -N zle-keymap-select

    function zle-line-finish {
        _PS_MODE="$I_CMD"
    }
    zle -N zle-line-finish

    case "$style" in
        ascii)
            PROMPT='%{$bg[cyan]%} %F{black}%~ $(_prompt_git)$reset_color
%f'
            ;;
        arrows)
            PROMPT='%{$bg[cyan]%}%F{black} %~ $(_prompt_git)$reset_color
%f'
            ;;
        ninja)
            PROMPT='%F{white}
        ▟▙  ${_PS_LVL}%25<..<%~%<<  %F{white}$(_prompt_git) %F{white}
▟▒${_PS_LVL}░░░░░░░%F{white}▜▙▜████████████████████████████████▛
▜▒${_PS_LVL}░░░░░░░%F{white}▟▛▟▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▛
        ▜▛
            ${_PS_MODE} %f'
            ;;
        dual)
            PROMPT='${_PS_LVL}┌[%F{white}%~${_PS_LVL}]$(_prompt_git)
${_PS_LVL}└${_PS_LINE} %f'
            ;;
        minimal)
            PROMPT='%F{white}
$(_prompt_git)${_PS_LVL}${_PS_MODE} %f'
            ;;
        classic|*)
            PROMPT='${_PS_LVL}
[%F{white}%~${_PS_LVL}]$(_prompt_git)${_PS_LINE} %f'
            ;;
    esac

    echo "Prompt style set to: $style"
    echo "Available styles: minimal, classic, dual, ascii, arrows, ninja"
}
