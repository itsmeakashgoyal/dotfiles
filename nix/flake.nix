#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ nix/flake.nix
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
# Standalone Home Manager flake — manages CLI *packages* on Linux/Ubuntu.
# This REPLACES linuxbrew as the package installer. It does NOT manage
# dotfiles: GNU Stow continues to symlink your zsh/nvim/tmux configs.
#
# macOS is untouched and keeps using Homebrew (packages/Brewfile).
#
# Usage:
#   make nix-setup     # first-time install (installs Nix + applies this)
#   make nix-switch    # apply changes after editing home.nix
#   make nix-update    # update package versions (flake update + switch)

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
    let
      lib = nixpkgs.lib;

      # ════════════════════════════════════════════════════════════════
      #  EDIT: add your Linux `$USER` to this list.
      #  "runner" is the GitHub CI user. The architecture is auto-detected
      #  — no `system` line to maintain.
      # ════════════════════════════════════════════════════════════════
      users = [ "akashgoyal" "runner" ];

      # Architectures we build for. The tooling (scripts/setup/nix.sh and the
      # Makefile) picks the one matching the host via `uname -m`.
      systems = [ "x86_64-linux" "aarch64-linux" ];
      # ════════════════════════════════════════════════════════════════

      mkHome = system: username: home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit username; };
      };
    in
    {
      # One config per (user, system), named "<user>-<system>", e.g.
      #   akashgoyal-x86_64-linux   runner-aarch64-linux   …
      # Applied via:  home-manager switch --flake ./nix#<user>-<system>
      # `make nix-*` and scripts/setup/nix.sh compute the right name for you.
      homeConfigurations = builtins.listToAttrs (
        lib.concatMap
          (system: map
            (username: {
              name = "${username}-${system}";
              value = mkHome system username;
            })
            users)
          systems
      );
    };
}
