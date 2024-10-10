{ config, pkgs, ... }:
{
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    fanbox-dl
  ];
  home.stateVersion = "24.05";
}
