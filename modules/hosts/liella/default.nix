{
  lib,
  modules,
  pkgs,
  inputs,
  config,
  ...
}:

let
  users = [ "violet" ];
in
{
  imports = [
    ./hardware-configuration.nix
    modules.nixos.mixins.builders
    modules.nixos.mixins.hardware.intel
    modules.nixos.mixins.hardware.gpu.intel
    modules.nixos.mixins.lanzaboote
    modules.nixos.mixins.home-manager
    modules.nixos.mixins.desktop.plasma
    modules.nixos.mixins.net.networkd-wifi
    inputs.disko.nixosModules.default
    modules.nixos.mixins.steam
    modules.disko.luks-xfs
  ]
  ++ builtins.map (user: modules.nixos.mixins.users.${user}) users;
  home-manager.users = lib.genAttrs users (
    user: modules.homes.x86_64-linux."${user}@${config.networking.hostName}"
  );
  boot.kernelPackages = pkgs.linuxPackages_latest;
  disko.devices.disk.root.device = "/dev/disk/by-path/pci-0000:6e:00.0-nvme-1";
  hardware.bluetooth.enable = true;
  virtualisation.podman.enable = true;
  system.stateVersion = "24.11";
}
