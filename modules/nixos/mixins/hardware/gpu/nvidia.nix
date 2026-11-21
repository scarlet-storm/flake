{ lib, ... }: {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    branch = lib.mkDefault "latest";
    open = true;
    powerManagement.enable = true;
    videoAcceleration = false;
  };
}
