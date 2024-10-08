{
  homeManagerModules,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./violet.nix
  ];
  services.syncthing.enable = true;
  home.packages = [
    pkgs.zed-editor
  ];
  home.stateVersion = "24.05";
}
