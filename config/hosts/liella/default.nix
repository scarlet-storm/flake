{
  lib,
  nixosConfig,
  pkgs,
  inputs,
  name,
  homes,
  diskoConfig,
  ...
}:

let
  users = [ "violet" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./net.nix
    nixosConfig.builders
    nixosConfig.hardware.intel
    nixosConfig.hardware.gpu.intel
    nixosConfig.lanzaboote
    inputs.disko.nixosModules.default
    nixosConfig.home-manager
    nixosConfig.desktop.plasma
    diskoConfig.luks-btrfs
  ] ++ builtins.map (user: nixosConfig.users.${user}) users;
  home-manager.users = lib.genAttrs users (user: homes."${user}@${name}");
  disko.devices.disk.root.device = "/dev/disk/by-path/pci-0000:6e:00.0-nvme-1";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = "24.11";
}
