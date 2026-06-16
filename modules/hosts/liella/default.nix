{ inputs, ... }:
{
  lib,
  pkgs,
  config,
  ...
}:

let
  users = [ "violet" ];
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.mixins.builders
    inputs.self.nixosModules.mixins.hardware.intel
    inputs.self.nixosModules.mixins.hardware.gpu.intel
    inputs.self.nixosModules.mixins.lanzaboote
    inputs.self.nixosModules.mixins.home-manager
    inputs.self.nixosModules.mixins.desktop.plasma
    inputs.self.nixosModules.mixins.net.networkd-wifi
    inputs.disko.nixosModules.default
    inputs.self.nixosModules.mixins.steam
    inputs.self.diskoConfigurations.luks-xfs
  ]
  ++ map (user: inputs.self.nixosModules.mixins.users.${user}) users;
  home-manager.users = lib.genAttrs users (
    user: inputs.self.homeModules.nixos-homes."${user}@${config.networking.hostName}"
  );
  boot.kernelPackages = pkgs.linuxPackages_latest;
  disko.devices.disk.root.device = "/dev/disk/by-path/pci-0000:6e:00.0-nvme-1";
  hardware.bluetooth.enable = true;
  virtualisation.podman.enable = true;
  system.stateVersion = "24.11";
}
