#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.zshenv
# ░▓▓▓▓▓▓▓▓▓▓
#
# ------------------------------------------------------------------------------
# Zsh Environment Configuration
# ------------------------------------------------------------------------------
# .zshenv is sourced on all shell invocations
# It should contain:
# - Environment variables
# - Command search path
# - Other important environment settings
# Note: Avoid commands that produce output or assume tty attachment

# ------------------------------------------------------------------------------
# XDG Base Directory Specification
# ------------------------------------------------------------------------------
# https://specifications.freedesktop.org/basedir-spec/latest/
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
# XDG_RUNTIME_DIR is owned by the OS: systemd sets /run/user/$UID on Linux, and
# macOS has none (apps use $TMPDIR). Overriding it broke things that use it as
# a socket directory: Rex's CLI then looked for a different server and started
# a second one. Leave it alone; only Linux without systemd gets a private dir.
if [[ $OSTYPE == linux* && -z ${XDG_RUNTIME_DIR-} ]]; then
    export XDG_RUNTIME_DIR="${HOME}/.runtime"
    [[ -d $XDG_RUNTIME_DIR ]] || { mkdir -p -m 700 "$XDG_RUNTIME_DIR" 2>/dev/null; }
fi
# Self-locate via the currently-sourced file's real path (%x) rather than
# hardcoding ~/dotfiles, so this still resolves correctly if the repo lives
# somewhere else. :A resolves the ~/.zshenv symlink to its real target
# (.../dotfiles/zsh/.zshenv); :h:h walks up past zsh/ and .zshenv to the
# repo root.
export XDG_DOTFILES_DIR="${${${(%):-%x}:A}:h:h}"

# Locale and TTY (safe in all shells)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export GPG_TTY=$TTY

# A real terminal always sets $TERM; a non-interactive invocation with no
# controlling tty (CI, `zsh -c '...'`, a Docker build step) does not. Zinit's
# plugin-install UI shells out to `tput` for its progress display and doesn't
# degrade gracefully when that fails - it aborts the whole shell startup.
# Falling back to a sane default here (only when unset) keeps sourcing this
# config robust in those contexts without affecting real terminal sessions.
: "${TERM:=xterm-256color}"
export TERM

# ------------------------------------------------------------------------------
# Application Paths
# ------------------------------------------------------------------------------
export ZDOTDIR="${XDG_CONFIG_HOME}/zsh"
