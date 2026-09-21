#
#  ▓▓▓▓▓▓▓▓▓▓
# ░▓ author ▓ Akash Goyal
# ░▓ file   ▓ nix/home.nix
# ░▓▓▓▓▓▓▓▓▓▓
#
# Home Manager module — the Nix equivalent of brew/Brewfile.
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
  # Packages — mirrors the CLI tools in brew/Brewfile
  # Search names at https://search.nixos.org/packages
  # ──────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # BEGIN GENERATED: nix (dutils manifest generate)
    # Essential CLI Tools
    git # Real git (macOS ships only a Command Line Tools stub)
    age # Modern file encryption (secrets, via dutils secrets)
    atuin # Shell history search (Rust)
    bat # Cat with syntax highlighting (Rust)
    eza # Better ls (Rust)
    fastfetch # System info tool (C)
    fd # Better find (Rust)
    gh # GitHub CLI
    delta # Better git diff (Rust) (Homebrew: git-delta)
    git-extras # Extra git commands
    hyperfine # Command-line benchmarking tool (Rust)
    jq # JSON processor
    lazygit # Terminal UI for git
    mise # Runtime version manager (replaces pyenv)
    uv # Fast Python venv/package manager (Rust) - works with mise-pinned interpreters
    starship # Cross-shell prompt (default, replaced Powerlevel10k)
    ripgrep # Better grep (Rust)
    tree # Directory tree
    television # Fuzzy finder with channels (Rust)
    yazi # Terminal file manager (Rust)
    zoxide # Smart cd (Rust)

    # System Monitoring
    btop # System monitor
    htop # Process viewer
    procs # Better ps (Rust)

    # Editors
    neovim # Vim-based text editor

    # Lua Toolchain
    lua # Lua interpreter
    lua-language-server # Lua LSP server
    luarocks # Lua package manager
    stylua # Lua formatter

    # Shell Tooling
    shellcheck # Shell script linter
    shfmt # Shell formatter
    nixfmt-rfc-style # Nix formatter (RFC 166 style; matches the CI check) (Homebrew: nixfmt)

    # Nix Tooling
    nixd # Nix language server (for editing home.nix / flake.nix in nvim)
    devenv # Reproducible per-project dev environments (see docs/NIX.md)

    # Misc
    rsync # File sync
    tealdeer # Simplified man pages (Nix provides the tealdeer client) (Homebrew: tldr)
    stow # Dotfile manager (Windows uses windows.ps1's symlink map instead)
    gettext # GNU i18n utilities
    # END GENERATED: nix
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
