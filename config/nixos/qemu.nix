{
  pkgs,
  config,
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
            qemu = config.virtualisation.libvirtd.qemu.package;
            msVarsTemplate = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
  systemd.services.libvirt-guests.unitConfig.After = [ "network-online.target" ];
  systemd.services.libvirt-guests.unitConfig.Wants = [ "network-online.target" ];
  systemd.services.libvirtd.path = [ pkgs.passt ];
}
