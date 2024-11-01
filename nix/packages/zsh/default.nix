{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    history = {
      extended = true;
      ignoreSpace = true;
      share = false;
    };
    profileExtra = "if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi";
  };
}