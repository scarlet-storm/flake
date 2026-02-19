{ config, lib, ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
    videoAcceleration = false;
  };
}
