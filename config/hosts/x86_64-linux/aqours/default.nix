{
  config,
  lib,
  pkgs,
  inputs,
  modules,
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
    modules.nixos.hardware.amd
    modules.nixos.hardware.gpu.nvidia
    modules.nixos.lanzaboote.default
    modules.nixos.home-manager
    modules.nixos.desktop.plasma
    modules.nixos.net.networkd-wifi
    inputs.disko.nixosModules.default
    modules.disko.luks-btrfs
  ] ++ builtins.map (user: modules.nixos.users.${user}) users;
  home-manager.users = lib.genAttrs users (user: modules.homes."${user}@${systemName}");
  # ethernet device
  boot.kernelPackages = pkgs.linuxPackages_testing;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  disko.devices.disk.root.device = "/dev/disk/by-path/pci-0000:09:00.0-nvme-1";
  hardware.bluetooth.enable = true;
  system.stateVersion = "24.11";
}
