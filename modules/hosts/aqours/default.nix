{ inputs, ... }:
{
  lib,
  pkgs,
  config,
  ...
}:

let
  users = [ "violet" ];
  systemd-homework = pkgs.systemd.overrideAttrs (prevAttrs: {
    patches = prevAttrs.patches ++ [ ./discard.patch ];
  });
in
{
  imports = [
    ./hardware-configuration.nix
    inputs.self.nixosModules.mixins.builders
    inputs.self.nixosModules.mixins.hardware.amd
    inputs.self.nixosModules.mixins.hardware.gpu.nvidia
    inputs.self.nixosModules.mixins.lanzaboote
    inputs.self.nixosModules.mixins.desktop.plasma
    inputs.self.nixosModules.mixins.net.networkd-wifi
    inputs.self.nixosModules.mixins.qemu
    inputs.disko.nixosModules.default
    inputs.self.diskoConfigurations.luks-btrfs
    inputs.self.nixosModules.mixins.steam
    inputs.self.nixosModules.services.OpenLinkHub
  ]
  ++ map (user: inputs.self.nixosModules.mixins.users.${user}) users;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  disko.devices.disk.root.device = "/dev/disk/by-path/pci-0000:09:00.0-nvme-1";
  programs.virt-manager.enable = true;
  hardware.bluetooth.enable = true;
  services.OpenLinkHub.package = pkgs.OpenLinkHub.override {
    withNvidia = true;
    nvidiaPackage = config.hardware.nvidia.package;
  };
  services.OpenLinkHub.enable = true;
  # services.hardware.openrgb.enable = true;
  # services.hardware.openrgb.package = pkgs.openrgb.overrideAttrs (prevAttrs: {
  #   version = "20241110";
  #   src = pkgs.fetchFromGitLab {
  #     owner = "CalcProgrammer1";
  #     repo = "OpenRGB";
  #     rev = "7a69aef99b6772005af469bf9b69f22fd83616d7";
  #     hash = "sha512-karAIFGvXMl/IKK7sTtTlR4y4Rx1YdlKqneCIP8B7kEgMBK3NwyUvO1mYjGC4JN7WFVWFbP9hBxhrA/pO1Zt8A==";
  #     leaveDotGit = true;
  #   };
  #   postPatch = ''
  #     substituteInPlace scripts/build-udev-rules.sh \
  #       --replace /usr/bin/env ${pkgs.coreutils-full}/bin/env
  #   '';
  #   nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ pkgs.git ];
  # });
  services.nixseparatedebuginfod2.enable = true;
  systemd.network.networks."90-lan".networkConfig.MulticastDNS = true;
  services.hardware.bolt.enable = true;
  virtualisation.podman.enable = true;
  environment.systemPackages = with pkgs; [ distrobox ];
  systemd.services.systemd-homed.environment = {
    "SYSTEMD_HOMEWORK_PATH" = "${systemd-homework}/lib/systemd/systemd-homework";
  };
  services.homed.enable = true;
  networking.firewall.allowedTCPPorts = [ 24800 ]; # input-leap
  system.stateVersion = "24.11";
  systemd.oomd.enable = true;
  systemd.oomd.enableRootSlice = true;
  boot.kernelParams = [ "split_lock_detect=off" ];
  boot.kernelModules = [ "ntsync" ];
  boot.extraModprobeConfig = ''
    options btusb enable_autosuspend=N
  '';
}
