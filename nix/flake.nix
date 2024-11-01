{
  description = "My Nix flake for Ubuntu";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs, and flake-utils.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      user = "ir";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      formatter.${system} = pkgs.alejandra;

      homeConfigurations = {
        "${user}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [ ./home.nix ];

          # Provide the activation package
          activationPackage = pkgs.home-manager.activationPackage;
        };
      };
    };
}