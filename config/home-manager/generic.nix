{ pkgs, nixgl, ... }:
{
  nixpkgs.overlays = [ nixgl.overlay ];
  targets.genericLinux.enable = true;
  systemd.user = {
    systemctlPath = "/usr/bin/systemctl";
    sessionVariables = {
      # Disable autocreation of profiles based on firefox path
      MOZ_LEGACY_PROFILES = 1;
    };
  };
  programs.man.package = pkgs.man.override { db = pkgs.gdbm; };
}
