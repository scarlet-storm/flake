{ pkgs, ... }:
{
  home.file.".ssh/config" = {
    target = ".ssh/config_store";
    text = ''
      Host *
        ServerAliveInterval 20
        ServerAliveCountMax 6
        ControlMaster auto
        ControlPath ''${HOME}/.cache/ssh/control/%C
        ControlPersist 10m
    '';
    onChange = ''
      install -m 0400 .ssh/config_store .ssh/config
    '';
  };
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    package = pkgs.openssh;
  };
  systemd.user = {
    tmpfiles.rules = [ "D %C/ssh/control - - - - -" ];
  };
}
