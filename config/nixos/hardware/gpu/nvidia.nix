{
  config,
  lib,
  pkgs,
  modules,
  ...
}:

{
  imports = [
    modules.nixos.unfree
  ];
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    package = lib.mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
  };
  # hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ];
  unfree.packageList = [
    "nvidia-settings"
    "nvidia-x11"
  ];
}
