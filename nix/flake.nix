#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ nix/flake.nix
# ░▓▓▓▓▓▓▓▓▓▓
#
# Standalone Home Manager flake — the only package manager used on Linux (no
# linuxbrew, no Homebrew). Manages CLI *packages* only: GNU Stow still
# symlinks your zsh/nvim/tmux configs, this doesn't touch that.
#
# macOS is untouched and keeps using Homebrew (packages/Brewfile).
#
# Usage:
#   make nix-setup     # first-time install (installs Nix + applies this)
#   make nix-switch    # apply changes after editing home.nix
#   make nix-update    # update package versions (flake update + switch)
#
# One dynamic config, not one per (user, system): reads $USER and the
# current architecture at apply-time instead of maintaining a list of
# usernames/systems to keep in sync. This needs --impure (already passed by
# scripts/setup/nix.sh) since flakes otherwise evaluate hermetically — a
# reasonable trade here, since a personal home-manager config was never
# meant to be bit-reproducible across machines/users the way a NixOS system
# config is.

{
  description = "Akash's Home Manager config (Linux CLI packages via Nix)";

  inputs = {
    # nixos-unstable tracks the freshest tool versions — the same reason you
    # reached for Homebrew. Pin to a stable release (e.g. nixos-24.11) if you
    # prefer slower, more tested updates.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    {
      # Applied via:  home-manager switch --flake ./nix#default --impure
      # scripts/setup/nix.sh always uses this one name — no per-machine edits.
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = builtins.currentSystem;
          config.allowUnfree = true;
        };
        modules = [ ./home.nix ];
        extraSpecialArgs = { username = builtins.getEnv "USER"; };
      };
    };
}
