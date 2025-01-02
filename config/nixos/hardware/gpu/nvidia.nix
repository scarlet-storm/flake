{
  config,
  lib,
  modules,
  pkgs,
  ...
}:

{
  imports = [ modules.nixos.unfree ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    package = lib.mkDefault (
      config.boot.kernelPackages.nvidiaPackages.beta
      // {
        open = config.boot.kernelPackages.nvidiaPackages.beta.open.overrideAttrs (prevAttrs: {
          patches = prevAttrs.patches ++ [
            (pkgs.fetchpatch {
              url = "https://gitlab.archlinux.org/archlinux/packaging/packages/nvidia-utils/-/raw/2432b41b0946e035f133e733e604d41697a8afd5/silence-event-assert-until-570.patch";
              hash = "sha256-0quYUU7mWDNgd81IzXlmVkch/zSPW9NxvIm4RlzEldA=";
            })
          ];
        });
      }
    );
  };
  unfree.packageList = [
    "nvidia-settings"
    "nvidia-x11"
  ];
  boot.kernelModules = [
    "nvidia"
    "nvidia-modeset"
    "nvidia-drm"
    "nvidia-uvm"
  ];
}
