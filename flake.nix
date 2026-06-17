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
      url = "github:nix-community/lanzaboote/001e560fffc8f0235e9db20ebeb4ccde0ade1caf";
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
      mylib = import ./lib { inherit lib; };
      callModule =
        path:
        let
          module = import path;
        in
        if builtins.isFunction module && (builtins.functionArgs module) ? inputs then
          module { inherit inputs; }
        else
          module;
      modules = mylib.modulesFromDirectory {
        inherit callModule;
        directory = ./modules;
      };
      overlays = (import ./overlays) { inherit lib; };
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
      nixosModules = modules.nixos;
      inherit overlays;
      nixosConfigurations = builtins.mapAttrs (
        systemName: host:
        lib.nixosSystem {
          modules = [
            ./nixpkgs.nix
            { networking.hostName = systemName; }
            {
              nixpkgs.overlays = [
                (final: prev: inputs.self.packages.${prev.stdenv.hostPlatform.system} or { })
                overlays.wrappers
              ];
            }
            modules.nixos.mixins.base
            host
          ];
        }
      ) modules.hosts;

      ### non-standard flake outputs ###
      homeConfigurations = lib.concatMapAttrs (
        system: homes:
        (lib.mapAttrs (
          home: config:
          (inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = inputs.nixpkgs.legacyPackages.${system};
            modules = [
              ./nixpkgs.nix
              { programs.home-manager.enable = true; }
              {
                nixpkgs.overlays = [
                  (final: prev: inputs.self.packages.${system})
                  overlays.wrappers
                ];
              }
              inputs.sops-nix.homeModules.sops
              inputs.plasma-manager.homeModules.plasma-manager
              config
            ];
          })
        ) homes)
      ) modules.homes;

      homeModules = modules.home-manager;
      lib = mylib;
      diskoConfigurations = modules.disko;
    };
}
