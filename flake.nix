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
    ghostty = {
      url = "github:ghostty-org/ghostty/tip";
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
      formatter = forAllSystems (
        system:
        (inputs.treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix)
        .config.build.wrapper
      );
      packages = forAllSystems (
        system:
        lib.filesystem.packagesFromDirectoryRecursive {
          callPackage = nixpkgs.legacyPackages.${system}.callPackage;
          directory = ./packages;
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
              { nixpkgs.overlays = [ (final: prev: inputs.self.packages.${system}) ]; }
              ./overlays
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
              { programs.home-manager.enable = true; }
              ./overlays
              {
                nixpkgs.overlays = [
                  (
                    final: prev:
                    inputs.self.packages.${system} // { ghostty = inputs.ghostty.packages.${system}.ghostty; }
                  )
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
      inherit configModules;
    };
}
