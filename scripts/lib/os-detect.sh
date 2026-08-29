#!/usr/bin/env bash
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ scripts/lib/os-detect.sh
# ░▓▓▓▓▓▓▓▓▓▓
#
# OS detection only — no logging, no side effects (no file/dir creation).
# Safe to source from anywhere, including zsh's interactive-shell startup
# path, unlike core.sh (which creates ~/linuxtoolbox and /tmp/dotfiles.log
# on source). core.sh sources this file for its bash consumers; zsh sources
# it directly for the same reason.
#
# Guard prevents double-sourcing (readonly below would otherwise error).
[[ -n "${OS_DETECT_LOADED:-}" ]] && return 0

OS_TYPE=$(uname)
readonly OS_TYPE

os::is_mac()   { [[ "$OS_TYPE" == "Darwin" ]]; }
os::is_linux() { [[ "$OS_TYPE" == "Linux"  ]]; }
os::arch()     { uname -m; }
os::detail() {
    local arch; arch=$(uname -m)
    case "${OS_TYPE},${arch}" in
        Linux,arm*|Linux,aarch64) echo "Linux (ARM)" ;;
        Linux,x86_64|Linux,amd64) echo "Linux (x86_64)" ;;
        Darwin,arm64)             echo "macOS (Apple Silicon)" ;;
        Darwin,x86_64)            echo "macOS (Intel)" ;;
        *)                        echo "Unknown: ${OS_TYPE} on ${arch}" ;;
    esac
}

# export -f is a bash-only construct — under zsh (which sources this file
# directly for interactive-shell startup, per conf.d/01-exports.zsh) it
# doesn't export the function, it prints the function body to stdout,
# which would spam every new shell's startup. Bash sub-shells need the
# real export; zsh doesn't need it at all (sourced functions are already
# usable in that same shell).
if [[ -n "${BASH_VERSION:-}" ]]; then
    export -f os::is_mac os::is_linux os::arch os::detail
fi
export OS_TYPE

readonly OS_DETECT_LOADED=true
export OS_DETECT_LOADED
