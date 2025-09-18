{ inputs, homeManagerExtraArgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        verbose = true;
        sharedModules = [
          inputs.plasma-manager.homeModules.plasma-manager
          inputs.sops-nix.homeModules.sops
        ];
        extraSpecialArgs = homeManagerExtraArgs;
      };
    }
  ];
}
