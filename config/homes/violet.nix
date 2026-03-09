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
  home.packages = [
    (pkgs.wrapPrivateHome {
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
    } (pkgs.discord.override { withTTS = false; }))
  ]
  ++ (with pkgs; [
    deskflow
    kopia
    keepassxc
    sops
    signal-desktop
    nixd
    nixfmt
    yubikey-manager
    virt-viewer
  ]);
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
