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
  systemd-homework = (pkgs.systemd.override { withFirstboot = true; }).overrideAttrs (prevAttrs: {
    patches = prevAttrs.patches ++ [
      (pkgs.fetchpatch2 {
        url = "https://patch-diff.githubusercontent.com/raw/systemd/systemd/pull/35776.patch";
        hash = "sha256-XWJTAobBmY2FHfysQ1yOf6skA/ZGlPc/A6ll4x3zLv4=";
      })
    ];
    meta.priority = 20;
    version = "20241228";
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
    modules.nixos.class.desktop
    modules.nixos.desktop.plasma
    modules.nixos.net.networkd-wifi
    modules.nixos.qemu
    inputs.disko.nixosModules.default
    modules.disko.luks-btrfs
    modules.nixos.steam
    inputs.self.nixosModules.services.OpenLinkHub
  ] ++ lib.map (user: modules.nixos.users.${user}) users;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  disko.devices.disk.root.device = "/dev/disk/by-path/pci-0000:09:00.0-nvme-1";
  programs.virt-manager.enable = true;
  hardware.bluetooth.enable = true;
  services.OpenLinkHub.package = inputs.self.packages.x86_64-linux.OpenLinkHub.override {
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
  services.nixseparatedebuginfod.enable = true;
  services.hardware.bolt.enable = true;
  virtualisation.podman.enable = true;
  environment.systemPackages = with pkgs; [
    distrobox
    gdb
    binutils
  ];
  systemd.services.systemd-homed.environment = {
    "SYSTEMD_HOMEWORK_PATH" = "${systemd-homework}/lib/systemd/systemd-homework";
  };
  boot.kernelPatches = [
    {
      name = "WCN785x-btusb";
      patch = ./Bluetooth-btusb-Add-one-more-ID-0x0489-0xe10a-for-Qualcomm-WCN785x.diff;
    }
  ];
  services.homed.enable = true;
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (
        kfinal: kprev: { qtwebengine = prev.emptyDirectory; }
      );
    })
  ];
  networking.firewall.allowedTCPPorts = [ 24800 ]; # input-leap
  programs.kde-pim.enable = false;
  system.stateVersion = "24.11";
  systemd.oomd.enable = true;
  systemd.oomd.enableRootSlice = true;
  boot.kernelParams = [ "split_lock_detect=off" ];
  environment.etc = rec {
    subuid.text = ''
      violet:524288:65536
    '';
    subgid = subuid;
  };
}
