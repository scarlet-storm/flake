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
    parallelShutdown = 2;
    onShutdown = "shutdown";
  };
  environment.systemPackages = [
    pkgs.passt
  ];
  systemd.services.libvirtd.path = [ pkgs.passt ];
}
