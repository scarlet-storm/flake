{ pkgs, homeManagerConfig, ... }:
let
  username = "kanata";
in
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };
  imports = [ homeManagerConfig.headless ];

  home.stateVersion = "24.11";
}
