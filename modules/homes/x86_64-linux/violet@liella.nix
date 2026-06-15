{ pkgs, modules, ... }:
let
  wallpapers = import modules.home-manager.mixins.users.violet.wallpapers {
    inherit (pkgs) fetchurl;
  };
in
{
  imports = [
    modules.home-manager.mixins.users.violet.default
    modules.home-manager.mixins.plasma
  ];
  services.syncthing.enable = true;
  programs.plasma.workspace.wallpaper = "${wallpapers.pShizukuIdolized}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "1,183,237";
  home.stateVersion = "24.05";
}
