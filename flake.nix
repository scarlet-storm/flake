{
  description = "Personal nix config";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
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
      formatter = forAllSystems (
        system:
        (inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix)
        .config.build.wrapper
      );
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
              homeManagerExtraArgs = { inherit homeManagerConfig; };
            };
          }
        ) modules.hosts.${system}
      ) modules.hosts;

      homeConfigurations = builtins.mapAttrs (
        name: config:
        (
          let
            pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          in
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              { programs.home-manager.enable = true; }
              ./overlays
              inputs.plasma-manager.homeManagerModules.plasma-manager
              config
            ];
            extraSpecialArgs = { inherit homeManagerConfig inputs; };
          }
        )
      ) modules.homes;
    };
}
