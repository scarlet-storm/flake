{
  description = "yet another Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nixos-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
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
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
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
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      config-modules = import ./config/modules.nix;
      flake-modules = import ./modules;
      hosts = import ./config/hosts.nix;
      homes = (import ./config/homes.nix) { lib = nixpkgs.lib; };
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      nixosModules = flake-modules.nixos;

      nixosConfigurations = builtins.mapAttrs (
        name: value:
        nixpkgs.lib.nixosSystem {
          inherit (value) system;
          modules = [
            { networking.hostName = name; }
            config-modules.nixos.base
            ./config/hosts/${name}
          ];
          specialArgs = {
            inherit inputs name;
            modules = config-modules;
            homes = homes.nixos;
          };
        }
      ) hosts;

      homeConfigurations = builtins.mapAttrs (
        name: homeModule:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs-unstable.legacyPackages.x86_64-linux;
          modules = [
            { programs.home-manager.enable = true; }
            inputs.plasma-manager.homeManagerModules.plasma-manager
            homeModule
          ];
          extraSpecialArgs = {
            homeManagerModules = config-modules.home-manager;
            inherit (inputs) nixgl;
          };
        }
      ) homes.standalone;
    };
}
