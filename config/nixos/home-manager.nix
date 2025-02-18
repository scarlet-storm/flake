{ inputs, homeManagerExtraArgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        verbose = true;
        sharedModules = [
          inputs.plasma-manager.homeManagerModules.plasma-manager
          inputs.sops-nix.homeManagerModules.sops
        ];
        extraSpecialArgs = homeManagerExtraArgs;
      };
    }
  ];
}
