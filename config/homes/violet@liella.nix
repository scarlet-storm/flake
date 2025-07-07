{ pkgs, homeManagerConfig, ... }:
let
  wallpapers = import ./wallpapers.nix { inherit (pkgs) fetchurl; };
in
{
  imports = [
    ./violet.nix
    homeManagerConfig.plasma
  ];
  services.syncthing.enable = true;
  programs.plasma.workspace.wallpaper = "${wallpapers.pShizukuIdolized}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "1,183,237";
  home.stateVersion = "24.05";
}
