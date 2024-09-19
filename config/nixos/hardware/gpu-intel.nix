{
  config,
  lib,
  pkgs,
  ...
}:

{
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
  hardware.enableRedistributableFirmware = true;
}
