{
  ...
}:

{
  boot.kernelParams = [ "amd_pstate=active" ];
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
}
