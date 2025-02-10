{ pkgs, homeManagerConfig, ... }:
{
  imports = [ ./violet.nix ];
  services.syncthing.enable = true;
  home.stateVersion = "24.05";
}
