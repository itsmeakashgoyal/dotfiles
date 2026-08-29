#!/usr/bin/env zsh
#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ zsh/.config/zsh/conf.d/15-nix.zsh
# ░▓▓▓▓▓▓▓▓▓▓
#
# Nix / Home Manager integration (Linux only).
#
# On Linux, CLI tools are installed via Nix + Home Manager (see nix/).
# This sources the Nix profile so those tools land on PATH in interactive
# shells. On macOS we use Homebrew, so this whole block is skipped.
#
# The Determinate installer also wires /etc/zshrc system-wide, so this is
# mostly belt-and-suspenders — but it guarantees the Home Manager session
# vars load even though we manage zsh via Stow (not programs.zsh).

if [[ "$(uname -s)" == "Linux" ]]; then
    # Nix daemon profile — puts `nix` and ~/.nix-profile/bin on PATH
    if [[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi

    # Home Manager session variables — ensures HM-installed packages are found
    if [[ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi
fi
