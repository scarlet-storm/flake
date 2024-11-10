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
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            msVarsTemplate = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
  environment.systemPackages = [
    pkgs.passt
  ];
  systemd.services.libvirtd.path = [ pkgs.passt ];
}
