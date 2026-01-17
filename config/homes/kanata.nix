{ pkgs, ... }:
let
  username = "kanata";
in
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };
  imports = [ ./base.nix ];

  home.stateVersion = "24.11";
}
