{ config, pkgs, ... }:
let
  username = "ir";
in
{
  # Uncomment below import packages when you feel that you are ready to use nix packages internally
  # imports = [
  #   ./packages
  # ];

  fonts.fontconfig.enable = true;

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home = {
    username = "${username}";
    homeDirectory = if pkgs.stdenv.isLinux then "/home/${username}" else "/Users/${username}";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05"; # Please read the comment before changing.

    packages = with pkgs; [
      bat
      cowsay
      delta
      diff-so-fancy
      fd
      go
      hello
      htop
      ipfetch
      jdk
      jq
      less
      neovim
      nerdfonts
      nix-direnv
      nixd
      ripgrep
      sshs
      terminus-nerdfont
      tldr
      tree
      unzip
      zip
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # ".zshrc".source = ~/dotfiles/zshrc/.zshrc;
      # ".gitconfig".source = ~/dotfiles/git/.gitconfig;
      # ".gitattributes".source = ~/dotfiles/git/.gitattributes;
      # ".gitignore".source = ~/dotfiles/git/.gitignore;
      # ".curlrc".source = ~/dotfiles/.curlrc;
      # ".gdbinit".source = ~/dotfiles/.gdbinit;
      # ".wgetrc".source = ~/dotfiles/.wgetrc;
      # ".config/nix".source = ~/dotfiles/nix;
      # ".config/nvim".source = ~/dotfiles/nvim;
      # ".config/tmux".source = ~/dotfiles/tmux;
    };

    sessionPath = [
      "$HOME/.nix-profile/bin"
    ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Let Home Manager install and manage itself.
  programs = {
    home-manager.enable = true;
    jq.enable = true;
  };
}