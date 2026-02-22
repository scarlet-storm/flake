{
  pkgs,
  lib,
  config,
  ...
}:
let
  commonConfig = {
    home = {
      homeDirectory = lib.mkDefault "/home/${config.home.username}";
    };
    programs = {
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
      carapace = {
        enable = true;
        enableZshIntegration = false;
      };
      direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
        };
      };
      fastfetch.enable = true;
      fd.enable = true;
      git = {
        enable = true;
        ignores = [ ".direnv" ];
      };
      go = {
        enable = true;
        env = {
          GOPATH = "${config.xdg.cacheHome}/go";
          GOBIN = "${config.xdg.dataHome}/go/bin";
        };
        package = lib.mkDefault null;
      };
      lazygit.enable = true;
      man = {
        enable = true;
        generateCaches = true;
      };
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
        extraConfig = ''
          load-env {
            SHELL: $nu.current-exe
          }
        '';
      };
      ripgrep.enable = true;
      skim.enable = true;
      starship = {
        enable = true;
      };
      zellij = {
        enable = true;
      };
      zoxide.enable = true;
      zsh.enable = true;
    };
    home.packages = (
      with pkgs;
      [
        kopia
        dua
      ]
    );
    systemd.user = {
      tmpfiles.rules = [ "D %C/ssh/control - - - - -" ];
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
            ControlPath ''${HOME}/.cache/ssh/control/%C
            ControlPersist 10m
        '';
        onChange = ''
          install -m 0400 .ssh/config_store .ssh/config
        '';
      };
      ".config/nushell/autoload".source = ./files/.config/nushell/autoload;
    };
  };
in
{
  imports = [ ./editor ];
  options.home = {
    desktopEnvironment = lib.mkOption {
      default = null;
      description = "Desktop Environment used for Home";
      type = lib.types.enum [
        null
        "cosmic"
        "gnome"
        "plasma"
      ];
    };
  };
  config = commonConfig;
}
