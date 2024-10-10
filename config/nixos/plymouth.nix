{ ... }:
{
  boot.plymouth.enable = true;
  boot.kernelParams = [ "quiet" ];
  boot.initrd.verbose = false;
}
