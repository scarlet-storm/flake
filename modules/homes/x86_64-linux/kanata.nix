{ modules, lib, ... }: {
  imports = [ modules.home-manager.mixins.common ];
  home.username = "kanata";

  home.stateVersion = lib.mkDefault "24.11";
}
