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
    # modules.nixos.hardware.gpu.nvidia
    modules.nixos.lanzaboote.default
    modules.nixos.home-manager
    modules.nixos.class.desktop
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
  boot.kernelPackages = pkgs.linuxPackages_testing;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  disko.devices.disk.root.device = "/dev/disk/by-path/pci-0000:09:00.0-nvme-1";
  programs.virt-manager.enable = true;
  hardware.bluetooth.enable = true;
  services.OpenLinkHub.package = inputs.self.packages.x86_64-linux.OpenLinkHub.override {
    # withNvidia = true;
    # nvidiaPackage = config.hardware.nvidia.package;
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
  boot.kernelPatches = [
    {
      name = "WCN785x-btusb";
      patch = ./Bluetooth-btusb-Add-one-more-ID-0x0489-0xe10a-for-Qualcomm-WCN785x.diff;
    }
  ];
  boot.kernelParams = [ "nouveau.config=NvGspRm=1" ];
  systemd.globalEnvironment = {
    "NOUVEAU_USE_ZINK" = "1";
  };
  boot.initrd.kernelModules = [ "nouveau" ];
  services.homed.enable = true;
  nixpkgs.overlays = [
    (final: prev: {
      mesa = prev.mesa.overrideAttrs (prevAttrs: {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "mesa";
          repo = "mesa";
          rev = "ed58b869e1ce68090d62297e06bae4afd24827be";
          hash = "sha512-O6VarKF2Z6zKoS8tPtMNJ9oFmnV1kTj4pGD+EoQLTOZc18RIqY9wPEL55XNj5cJdMhtZJoKkCyxw0LruDEHkNA==";
        };
        version = "20241221";
        patches = [ ];
        mesonFlags =
          builtins.filter (
            f:
            !builtins.any (opt: lib.hasPrefix "${opt}" f) [
              "-Ddri-search-path"
              "-Domx-libs-path"
              "-Dopencl-spirv"
              "-Dclang-libdir"
              "--sysconfdir=/etc"
            ]
          ) prevAttrs.mesonFlags
          ++ [
          ];
        preConfigure =
          prevAttrs.preConfigure
          + ''
            substituteInPlace meson.build \
            --replace-fail "llvm_libdir = dep_llvm.get_variable(cmake : 'LLVM_LIBRARY_DIR', configtool: 'libdir')" \
            "llvm_libdir = '${lib.getLib prev.llvmPackages.clang-unwrapped}/lib'"
          '';
      });
      kdePackages = prev.kdePackages.overrideScope (
        kfinal: kprev: {
          qtwebengine = prev.emptyDirectory;
        }
      );
    })
  ];
  programs.kde-pim.enable = false;
  system.stateVersion = "24.11";
}
