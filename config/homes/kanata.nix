{ homeManagerConfig, lib, ... }:
{
  imports = [ homeManagerConfig.common ];
  home.username = "kanata";

  home.stateVersion = lib.mkDefault "24.11";
}
