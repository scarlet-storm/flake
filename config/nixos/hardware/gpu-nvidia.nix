{
  config,
  lib,
  pkgs,
  nixosConfig,
  ...
}:

{
  imports = [
    nixosConfig.unfree
  ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
    };
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  unfree.packageList = [
    "nvidia-settings"
    "nvidia-x11"
  ];
}
