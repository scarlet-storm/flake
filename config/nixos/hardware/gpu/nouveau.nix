{ pkgs, lib, ... }:

# TODO: create specialisation ?
{
  boot.kernelParams = [
    "nouveau.config=NvGspRm=1"
    "nouveau.modeset=1"
    "nouveau.runpm=0"
  ];
  boot.kernelModules = [ "nouveau" ];
}
