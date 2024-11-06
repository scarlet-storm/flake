{
  pkgs,
  lib,
  ...
}:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      swtpm.enable = true;
      ovmf = {
        enable = true;
      };
    };
  };
  environment.systemPackages = [
    pkgs.passt
  ];
  systemd.services.libvirtd.path = [ pkgs.passt ];
}
