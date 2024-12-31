{
  inputs,
  homeManagerExtraArgs,
  modules,
  ...
}:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    modules.nixos.unfree
    {
      home-manager = {
        useGlobalPkgs = true;
        verbose = true;
        sharedModules = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];
        extraSpecialArgs = homeManagerExtraArgs;
      };
    }
    { unfree.packageList = [ "discord" ]; }
  ];
}
