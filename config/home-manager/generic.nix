{
  config,
  lib,
  pkgs,
  nixgl,
  ...
}:
{
  nixpkgs.overlays = [ nixgl.overlay ];
  targets.genericLinux.enable = true;
  systemd.user = {
    systemctlPath = "/usr/bin/systemctl";
  };
}
