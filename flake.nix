{
  description = "Personal nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      ...
    }:
    let
      lib = nixpkgs.lib;
      flakeModules = lib.filesystem.packagesFromDirectoryRecursive {
        callPackage = path: _: path;
        directory = ./modules;
      };
      modules = lib.filesystem.packagesFromDirectoryRecursive {
        callPackage = path: _: path;
        directory = ./config;
      };
      homeManagerConfig = modules.home-manager;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
      secrets = import ./secrets;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      packages = forAllSystems (
        system:
        lib.filesystem.packagesFromDirectoryRecursive {
          callPackage = nixpkgs.legacyPackages.${system}.callPackage;
          directory = ./pkgs;
        }
      );
      nixosModules = flakeModules;

      nixosConfigurations = lib.concatMapAttrs (
        system: _:
        builtins.mapAttrs (
          systemName: config:
          lib.nixosSystem {
            inherit system;
            modules = [
              { networking.hostName = systemName; }
              ./overlays
              modules.nixos.base.default
              config.default
            ];
            specialArgs = {
              inherit
                inputs
                systemName
                modules
                secrets
                ;
              homeManagerExtraArgs = {
                inherit homeManagerConfig;
              };
            };
          }
        ) modules.hosts.${system}
      ) modules.hosts;

      homeConfigurations = builtins.mapAttrs (
        name: config:
        (
          let
            pkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
          in
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              { programs.home-manager.enable = true; }
              inputs.plasma-manager.homeManagerModules.plasma-manager
              ./overlays
              config
            ];
            extraSpecialArgs = {
              inherit homeManagerConfig;
              inherit (inputs) nixgl;
              mylib = import ./lib pkgs;
            };
          }
        )
      ) modules.homes.standalone;
    };
}
