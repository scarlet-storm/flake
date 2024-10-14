{
  config,
  lib,
  pkgs,
  modules,
  inputs,
  systemName,
  ...
}:

let
  users = [ "violet" ];
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.lix-module.nixosModules.default
    modules.nixos.builders.default
    modules.nixos.hardware.intel
    modules.nixos.hardware.gpu.intel
    modules.nixos.hardware.gpu.nvidia
    modules.nixos.lanzaboote.default
    modules.nixos.home-manager
    modules.nixos.desktop.plasma
    modules.nixos.plymouth
    modules.nixos.steam
    modules.nixos.net.networkd-wifi
  ] ++ builtins.map (user: modules.nixos.users.${user}) users;
  home-manager.users = lib.genAttrs users (user: modules.homes."${user}@${systemName}");
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
