{
  description = "Personal nix config";

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
      nixosConfig = import ./config/nixos;
      homeManagerConfig = import ./config/home-manager;
      diskoConfig = import ./config/disko;
      hosts = import ./config/hosts;
      homes = (import ./config/homes) { lib = nixpkgs.lib; };
      secrets = import ./secrets;
    in
    {
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      nixosModules = import ./modules;

      nixosConfigurations = builtins.mapAttrs (
        name: host:
        nixpkgs.lib.nixosSystem {
          inherit (host) system;
          modules = [
            { networking.hostName = name; }
            nixosConfig.base
            ./overlays
            host.config
          ];
          specialArgs = {
            inherit
              inputs
              name
              secrets
              nixosConfig
              diskoConfig
              ;
            homes = homes.nixos;
            homeManagerExtraArgs = {
              inherit homeManagerConfig;
            };
          };
        }
      ) hosts;

      homeConfigurations = builtins.mapAttrs (
        name: home:
        (
          let
            pkgs = inputs.nixpkgs-unstable.legacyPackages.${home.system};
          in
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              { programs.home-manager.enable = true; }
              inputs.plasma-manager.homeManagerModules.plasma-manager
              ./overlays
              home.config
            ];
            extraSpecialArgs = {
              inherit homeManagerConfig;
              inherit (inputs) nixgl;
              mylib = import ./lib pkgs;
            };
          }
        )
      ) homes.standalone;
    };
}
