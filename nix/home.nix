#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ nix/home.nix
# ░▓▓▓▓▓▓▓▓▓▓
# ░░░░░░░░░░
#
# Home Manager module — the Nix equivalent of packages/Brewfile.
# Mirrors the CLI tools your dotfiles depend on. Edit the list below,
# then run `make nix-switch` to apply.
#
# IMPORTANT: This file intentionally does NOT set `programs.zsh`,
# `programs.git`, etc. Your shell/editor/git configs stay managed by
# GNU Stow + Zinit exactly as before. Nix here is *only* a package
# manager — nothing more.

{ pkgs, username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Marks the HM release your config targets. Leave as-is once set —
  # changing it later can require manual migration. Safe to keep at 24.11.
  home.stateVersion = "24.11";

  # Let Home Manager manage itself, so `home-manager` stays on PATH.
  programs.home-manager.enable = true;

  # ──────────────────────────────────────────────────────────────────
  # Packages — mirrors the CLI tools in packages/Brewfile
  # Search names at https://search.nixos.org/packages
  # ──────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Essential CLI tools
    atuin # Shell history search
    bat # cat with syntax highlighting
    eza # Better ls
    fastfetch # System info
    fd # Better find
    gh # GitHub CLI
    delta # Better git diff (Homebrew: git-delta)
    git-extras # Extra git commands
    hyperfine # Command-line benchmarking tool
    jq # JSON processor
    lazygit # Terminal UI for git
    ripgrep # Better grep
    tree # Directory tree
    television # Fuzzy finder (solves the linuxbrew "no tv" gap cleanly)
    zoxide # Smart cd

    # System monitoring
    btop # System monitor
    htop # Process viewer
    procs # Better ps

    # Editor
    neovim # Vim-based editor

    # Lua toolchain (for Neovim config / plugins)
    lua
    lua-language-server
    luarocks
    stylua # Lua formatter

    # Shell tooling
    shellcheck # Shell linter
    shfmt # Shell formatter

    # Misc
    rsync # File sync
    tealdeer # Fast `tldr` client (provides the `tldr` command)

    # Dotfile + build helpers
    stow # We keep using Stow for dotfile symlinks
    git # Newer git than Ubuntu ships
    gettext # GNU i18n utilities (Linux-only in Brewfile)
  ];

  # ──────────────────────────────────────────────────────────────────
  # Fonts (optional) — uncomment to install Nerd Fonts via Nix.
  # Requires fontconfig; HM wires it up for you.
  # ──────────────────────────────────────────────────────────────────
  # fonts.fontconfig.enable = true;
  # home.packages = with pkgs; [
  #   nerd-fonts.fira-code
  #   nerd-fonts.jetbrains-mono
  #   nerd-fonts.meslo-lg
  # ];

  # ──────────────────────────────────────────────────────────────────
  # Session vars (optional). Your zsh exports already handle these, so
  # we leave them out to avoid double-management. Add here only if you
  # want a value available even outside an interactive zsh session.
  # ──────────────────────────────────────────────────────────────────
  # home.sessionVariables = {
  #   EDITOR = "nvim";
  # };
}
