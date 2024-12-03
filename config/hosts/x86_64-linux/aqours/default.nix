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
    modules.nixos.qemu
    inputs.disko.nixosModules.default
    modules.disko.luks-btrfs
    modules.nixos.steam
    inputs.self.nixosModules.services.OpenLinkHub
  ] ++ builtins.map (user: modules.nixos.users.${user}) users;
  home-manager.users = lib.genAttrs users (user: modules.homes."${user}@${systemName}");
  # ethernet device
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.nvidia.package =
    let
      patchesOpen = [
        (pkgs.fetchpatch2 {
          url = "https://github.com/Binary-Eater/open-gpu-kernel-modules/commit/8ac26d3c66ea88b0f80504bdd1e907658b41609d.patch";
          hash = "sha512-vOcoVLx/kUFRIjSHNkl/Vzs8RJUiPlI9mqOz6hVI1xk+uFxGnrbBTDJ4KX/QYmtTdvuoU4IGmUjN8sYRo6CTFg==";
        })
      ];
      driver = config.boot.kernelPackages.nvidiaPackages.beta;
    in
    driver // { open = driver.open.override { patches = patchesOpen; }; };
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
  boot.extraModulePackages = [ config.boot.kernelPackages.nct6687d ];
  services.nixseparatedebuginfod.enable = true;
  services.hardware.bolt.enable = true;
  virtualisation.podman.enable = true;
  environment.systemPackages = with pkgs; [
    distrobox
    gdb
    binutils
  ];
  system.stateVersion = "24.11";
}
