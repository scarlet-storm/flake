{
  config,
  lib,
  modules,
  ...
}:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.beta;
  };
  boot.kernelModules = [
    "nvidia"
    "nvidia-modeset"
    "nvidia-drm"
    "nvidia-uvm"
  ];
}
