{
  config,
  lib,
  pkgs,
  nixosConfig,
  inputs,
  name,
  homes,
  ...
}:

let
  users = [ "violet" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./net.nix
    inputs.lix-module.nixosModules.default
    nixosConfig.builders
    nixosConfig.hardware.intel
    nixosConfig.hardware.gpu.intel
    nixosConfig.hardware.gpu.nvidia
    nixosConfig.lanzaboote
    nixosConfig.home-manager
    nixosConfig.desktop.plasma
    nixosConfig.plymouth
    nixosConfig.steam
  ] ++ builtins.map (user: nixosConfig.users.${user}) users;
  home-manager.users = lib.genAttrs users (user: homes."${user}@${name}");
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.nvidia.prime = {
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };
  system.stateVersion = "24.11";
  services = {
    sunshine = {
      autoStart = true;
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
