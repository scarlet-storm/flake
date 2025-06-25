{ pkgs, ... }:
{
  programs = {
    bat.enable = true;
    starship = {
      enable = true;
    };
    fish.enable = true;
    atuin = {
      enable = true;
      daemon.enable = true;
      settings = {
        enter_accept = false;
        auto_sync = false;
        update_check = false;
      };
    };
    man.generateCaches = true;
    nushell = {
      enable = true;
      configFile.source = ./config.nu;
      plugins = (
        with pkgs.nushellPlugins;
        [
          formats
          gstat
        ]
      );
    };
    zoxide.enable = true;
  };
  home.packages = (
    with pkgs;
    [
      kopia
      fastfetch
      dua
      zellij
    ]
  );
  home.sessionVariables = {
    EDITOR = "vim";
  };
  systemd.user = {
    tmpfiles.rules = [ "D %t/ssh-control - - - - -" ];
    startServices = "sd-switch";
  };
  nix.gc = {
    automatic = true;
    frequency = "weekly";
    randomizedDelaySec = "1d";
    options = "--delete-older-than 7d";
  };
  home.file = {
    ".ssh/config" = {
      target = ".ssh/config_store";
      text = ''
        Host *
          ServerAliveInterval 20
          ServerAliveCountMax 6
          ControlMaster auto
          ControlPath ''${XDG_RUNTIME_DIR}/ssh-control/mux.%C
          ControlPersist 10m
      '';
      onChange = ''
        install -m 0400 .ssh/config_store .ssh/config
      '';
    };
  };
}
