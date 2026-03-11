{
  pkgs,
  homeManagerConfig,
  lib,
  ...
}:
{
  imports = [
    homeManagerConfig.common
    ./rclone.nix
    homeManagerConfig.firefox
  ];
  home = {
    username = "violet";
    desktopEnvironment = "plasma";
  };
  news.display = "silent";
  home.packages = (
    with pkgs;
    [
      deskflow
      kopia
      keepassxc
      sops
      signal-desktop
      nixd
      nixfmt
      yubikey-manager
      virt-viewer
      (wrapPrivateHome {
        id = "io.github.Faugus.faugus-launcher";
        dbus = {
          talks = [ "org.kde.StatusNotifierWatcher" ];
        };
        devices = [ "dri" ];
        roBinds = [ "-$HOME/.config/dconf" ];
      } faugus-launcher)
      (wrapPrivateHome {
        id = "com.heroicgameslauncher.hgl";
        dbus = {
          talks = [
            "org.kde.StatusNotifierWatcher"
            "org.freedesktop.ScreenSaver"
          ];
        };
        devices = [ "dri" ];
        extraBinds = [
          "$HOME/.local/share/Steam"
          "$HOME/.local/share/umu"
          "$HOME/Games"
        ];
        extraSetup = ''
          mkdir -p $HOME/.local/share/Steam
          mkdir -p $HOME/.local/share/umu
          mkdir -p $HOME/Games
        '';
      } heroic)
    ]
  );
  home.file = {
    ".kopiaignore".text = ''
      /.var
      /.cache
      /Downloads
      /src
      /.local
      /.config/emacs
      /.mozilla
      /bak
    '';
  };

  programs = {
    anki = {
      enable = true;
      addons = [ pkgs.ankiAddons.anki-connect ];
    };
    discord = {
      enable = true;
      package = pkgs.wrapPrivateHome {
        id = "com.discordapp.Discord";
        dbus = {
          talks = [
            "org.freedesktop.Notifications"
            "org.kde.StatusNotifierWatcher"
          ];
        };
        devices = [ "dri" ];
        # who knows why this doesn't start if x11 socket is not available ?
        x11 = true;
        extraArgs = [ "-p PrivateTmp=false" ];
      } (pkgs.discord.override { withTTS = false; });
    };
    git = {
      enable = true;
      includes = [
        {
          condition = "hasconfig:remote.*.url:*github.com*scarlet-storm/**";
          contents = {
            user = {
              name = "scarlet-storm";
              email = "12461256+scarlet-storm@users.noreply.github.com";
              signingKey = "~/.ssh/id_ed25519.pub";
            };
            commit.gpgSign = true;
            tag.gpgSign = true;
          };
        }
      ];
      signing = {
        format = "ssh";
      };
      lfs = {
        enable = true;
      };
    };
  };
  services = {
    ssh-agent.enable = true;
  };
  home.stateVersion = lib.mkDefault "24.05";
}
