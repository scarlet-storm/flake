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
      url = "github:nix-community/lanzaboote/v1.0.0";
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
      overlays = (import ./overlays) { inherit lib; };
      configModules = lib.filesystem.packagesFromDirectoryRecursive {
        callPackage = path: _: path;
        directory = ./config;
      };
      homeManagerConfig = configModules.home-manager;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = lib.genAttrs systems;
      secrets = import ./secrets;
    in
    {
      ### standard flake outputs ###
      formatter = forAllSystems (
        system:
        (inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix)
        .config.build.wrapper
      );
      packages = forAllSystems (
        system:
        lib.filesystem.packagesFromDirectoryRecursive {
          inherit (nixpkgs.legacyPackages.${system}) callPackage;
          directory = ./packages;
        }
      );
      nixosModules = flakeModules // {
        configs = configModules.nixos;
      };
      inherit overlays;

      # nixosConfigurations
      nixosConfigurations = lib.concatMapAttrs (
        system: _:
        builtins.mapAttrs (
          systemName: config:
          lib.nixosSystem {
            inherit system;
            modules = [
              configModules.nixpkgs
              { networking.hostName = systemName; }
              {
                nixpkgs.overlays = [
                  (final: prev: inputs.self.packages.${system})
                  overlays.wrappers
                ];
              }
              configModules.nixos.base.default
              config.default
            ];
            specialArgs = {
              inherit inputs systemName secrets;
              modules = configModules;
              homeManagerExtraArgs = { inherit homeManagerConfig secrets; };
            };
          }
        ) configModules.hosts.${system}
      ) configModules.hosts;

      ### non-standard flake outputs ###
      # homeConfigurations
      homeConfigurations = builtins.mapAttrs (
        name: config:
        (
          let
            system = "x86_64-linux";
            pkgs = inputs.nixpkgs.legacyPackages.${system};
          in
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              configModules.nixpkgs
              { programs.home-manager.enable = true; }
              {
                nixpkgs.overlays = [
                  (final: prev: inputs.self.packages.${system})
                  overlays.wrappers
                ];
              }
              inputs.sops-nix.homeModules.sops
              configModules.nixos.sops
              inputs.plasma-manager.homeModules.plasma-manager
              config
            ];
            extraSpecialArgs = { inherit homeManagerConfig secrets; };
          }
        )
      ) configModules.homes;

      # homeModules
      homeModules = {
        configs = configModules.home-manager;
      };
    };
}
