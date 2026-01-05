{ pkgs, ... }:
{
  programs = {
    starship = {
      enable = true;
    };
    fd.enable = true;
    zsh.enable = true;
    atuin = {
      enable = true;
      daemon.enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        enter_accept = false;
        auto_sync = false;
        update_check = false;
      };
    };
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
    man.generateCaches = true;
    nushell = {
      enable = true;
      plugins = (
        with pkgs.nushellPlugins;
        [
          formats
          gstat
          query
        ]
      );
      settings = {
        show_banner = "short";
        completions.algorithm = "fuzzy";
      };
      environmentVariables = {
        SHELL = "nu";
      };
    };
    ripgrep.enable = true;
    skim.enable = true;
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
    dates = "weekly";
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
    ".config/nushell/autoload".source = ./files/.config/nushell/autoload;
  };
}
