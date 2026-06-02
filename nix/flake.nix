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
      # ════════════════════════════════════════════════════════════════
      #  EDIT to match your machine(s)
      # ════════════════════════════════════════════════════════════════
      # Add your Linux `$USER` to this list. "runner" is the GitHub CI user.
      users = [ "akashgoyal" "runner" ];
      system = "x86_64-linux"; # use "aarch64-linux" on ARM (Pi, ARM VM)
      # ════════════════════════════════════════════════════════════════

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # One Home Manager config per username — same package set for all.
      mkHome = username: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
        extraSpecialArgs = { inherit username; };
      };
    in
    {
      # Applied via:  home-manager switch --flake ./nix#<username>
      # e.g.  ./nix#akashgoyal  or  ./nix#runner  (CI)
      homeConfigurations = nixpkgs.lib.genAttrs users mkHome;
    };
}
