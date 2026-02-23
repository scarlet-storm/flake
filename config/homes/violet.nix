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
    (pkgs.mylib.wrapPrivateHome "discord" {
      pkg = pkgs.discord;
      execName = "Discord";
      # why in **** hell is there two binaries ???
      postBuild = "rm -fv $out/bin/discord";
    })
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
