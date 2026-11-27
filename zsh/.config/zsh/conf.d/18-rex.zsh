#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/18-rex.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Rex only: report what the shell is running via Rex's Program Status Protocol
# (OSC 7501, https://www.superlogical.com/rex/docs/build/program-status).
#   - every command (except interactive programs) → "working": a spinner on
#     its tab while you're elsewhere
#   - one that ran ≥ $REX_STATUS_MIN_SECONDS (default 10) → "done" or "error"
#     with "<cmd> · took 2m 5s · exit 1": tab/session marker + a macOS
#     notification if Rex is in the background (make rex enables it)
# Short commands and Ctrl-C leave nothing behind (Rex drops "working" at the
# next prompt). Fork-free: printf builtin, $EPOCHREALTIME, pure-zsh base64.

[[ "$TERM_PROGRAM" == "rex" ]] || return 0

zmodload zsh/datetime 2>/dev/null
: "${REX_STATUS_MIN_SECONDS:=10}"

# Programs that sit waiting for you (editors, pagers, TUIs, REPLs, agents that
# report their own status) shouldn't show a "working" spinner.
typeset -ga _rex_interactive=(vi vim nvim nano less more man ssh mosh tmux top htop btop
                               yazi tv fzf watch claude opencode codex gemini)
typeset -ga _rex_repl=(python python3 node irb lua ipython)   # only without args

typeset -g _rex_cmd="" _rex_app="" _rex_start=""

# Standard base64 of a string's UTF-8 bytes, in $REPLY.
_rex_b64() {
    emulate -L zsh
    setopt no_multibyte
    local s=$1 tbl='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local -i i n=${#s} b
    local c1 c2 c3
    REPLY=""
    for (( i = 1; i <= n; i += 3 )); do
        c1=${s[i]} c2=${s[i+1]} c3=${s[i+2]}
        b=$(( #c1 << 16 ))
        (( i + 1 <= n )) && b+=$(( #c2 << 8 ))
        (( i + 2 <= n )) && b+=$(( #c3 ))
        REPLY+=${tbl[$(( (b >> 18) & 63 ))+1]}${tbl[$(( (b >> 12) & 63 ))+1]}
        (( i + 1 <= n )) && REPLY+=${tbl[$(( (b >> 6) & 63 ))+1]} || REPLY+='='
        (( i + 2 <= n )) && REPLY+=${tbl[$(( b & 63 ))+1]}      || REPLY+='='
    done
}

_rex_status_preexec() {
    emulate -L zsh
    local -a words=(${(z)1})
    # Skip env assignments / sudo / command / exec / time to find the program.
    while (( $#words )) && [[ $words[1] == *=* || $words[1] == (sudo|command|exec|time|noglob|nocorrect) ]]; do
        shift words
    done
    local prog=${words[1]:t}
    _rex_cmd="" _rex_start=""
    [[ -z $prog ]] && return
    (( ${_rex_interactive[(Ie)$prog]} )) && return
    (( ${_rex_repl[(Ie)$prog]} && $#words == 1 )) && return
    _rex_cmd=$1 _rex_start=$EPOCHREALTIME
    _rex_app=${${prog//[^A-Za-z0-9_.+-]/}[1,32]}
    printf '\e]7501;state=working:app=%s\e\\' "${_rex_app:-shell}"
}

_rex_status_precmd() {
    local -i code=$?
    emulate -L zsh
    [[ -z $_rex_start ]] && return
    local -i secs=$(( EPOCHREALTIME - _rex_start ))
    _rex_start=""
    # Fast commands, and Ctrl-C (130), leave no record behind.
    (( secs < REX_STATUS_MIN_SECONDS || code == 130 )) && return
    local took
    if (( secs >= 3600 )); then took="$(( secs / 3600 ))h $(( secs % 3600 / 60 ))m"
    elif (( secs >= 60 )); then took="$(( secs / 60 ))m $(( secs % 60 ))s"
    else took="${secs}s"; fi
    local cmd=${${_rex_cmd//[[:cntrl:]]/ }[1,80]}
    local state=done msg="$cmd · took $took"
    (( code )) && state=error msg+=" · exit $code"
    _rex_b64 "$msg"
    printf '\e]7501;state=%s:app=%s:msg=%s\e\\' $state "${_rex_app:-shell}" "$REPLY"
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _rex_status_preexec
# First in precmd, so it sees the command's real exit status ($?).
precmd_functions=(_rex_status_precmd ${precmd_functions:#_rex_status_precmd})
