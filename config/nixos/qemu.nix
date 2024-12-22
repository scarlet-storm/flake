{
  pkgs,
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
      verbatimConfig = ''
        namespaces = []
        seccomp_sandbox = 0
        cgroup_device_acl = [
          "/dev/null", "/dev/full", "/dev/zero",
          "/dev/random", "/dev/urandom",
          "/dev/ptmx", "/dev/kvm", "/dev/udmabuf",
          "/dev/nvidiactl", "/dev/nvidia0", "/dev/nvidia-modeset", "/dev/dri/renderD128", "/dev/dri/renderD129"
        ]
      '';
    };
  };
  systemd.services.libvirt-guests.unitConfig.After = [ "network-online.target" ];
  systemd.services.libvirt-guests.unitConfig.Wants = [ "network-online.target" ];
  systemd.services.libvirtd.path = [ pkgs.passt ];
  users.users.qemu-libvirtd.extraGroups = [
    "kvm"
  ];
}
