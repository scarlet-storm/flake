{
  lib,
  pkgs,
  config,
  inputs,
  modules,
  ...
}:

let
  users = [ "violet" ];
  systemd-homework = pkgs.systemd.overrideAttrs (prevAttrs: {
    src = pkgs.fetchFromGitHub {
      repo = "systemd";
      owner = "systemd";
      rev = "v259-rc2";
      hash = "sha256-2iD7SMxGaD6wBkAfQlWZZg6ibkjJl9vxinN8UA5oxAM=";
    };
    version = "259-rc2";
    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/systemd/systemd/compare/329ec5278d9218bee367c96deec5bea8a9c1047c.patch";
        hash = "sha256-47QVaJqEhcpP9Gv1/ubRABj8UIWzP0lcxpHbxTdlQiE=";
      })
      ./discard.patch
    ];
    mesonFlags = prevAttrs.mesonFlags ++ [
      "--sysconfdir=${placeholder "out"}/etc"
      "--localstatedir=${placeholder "out"}/var"
    ];
    doCheck = false;
    dontCheckForBrokenSymlinks = true;
  });
in
{
  imports = [
    ./hardware-configuration.nix
    modules.nixos.builders.default
    modules.nixos.hardware.amd
    modules.nixos.hardware.gpu.nvidia
    modules.nixos.lanzaboote.default
    # modules.nixos.home-manager
    modules.nixos.desktop.plasma
    modules.nixos.net.networkd-wifi
    modules.nixos.qemu
    inputs.disko.nixosModules.default
    modules.disko.luks-btrfs
    modules.nixos.steam
    inputs.self.nixosModules.services.OpenLinkHub
  ]
  ++ lib.map (user: modules.nixos.users.${user}) users;
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
}
