{
  lib,
  modules,
  pkgs,
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
    modules.nixos.builders.default
    modules.nixos.hardware.intel
    modules.nixos.hardware.gpu.intel
    modules.nixos.lanzaboote.default
    modules.nixos.home-manager
    modules.nixos.desktop.plasma
    modules.nixos.net.networkd-wifi
    inputs.disko.nixosModules.default
    modules.nixos.steam
    modules.disko.luks-btrfs
  ] ++ builtins.map (user: modules.nixos.users.${user}) users;
  home-manager.users = lib.genAttrs users (user: modules.homes."${user}@${systemName}");
  boot.kernelPackages = pkgs.linuxPackages_latest;
  disko.devices.disk.root.device = "/dev/disk/by-path/pci-0000:6e:00.0-nvme-1";
  hardware.bluetooth.enable = true;
  system.stateVersion = "24.11";
}
