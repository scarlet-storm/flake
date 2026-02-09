{ pkgs, homeManagerConfig, ... }:
let
  username = "violet";
in
{
  imports = [
    ./base.nix
    ./rclone.nix
    ./editor
    homeManagerConfig.firefox
  ];
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
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
    carapace = {
      enable = true;
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
      ignores = [ ".direnv" ];
      signing = {
        format = "ssh";
      };
      lfs = {
        enable = true;
      };
    };
    mpv = {
      enable = true;
      config = {
        cache = "yes";
        demuxer-max-bytes = "4GiB";
        vo = "gpu-next,dmabuf-wayland,gpu";
        ao = "pipewire,alsa";
        gpu-context = "waylandvk,wayland,drm";
        gpu-api = "vulkan,opengl";
        hwdec = "vulkan,vaapi,drm";
      };
    };
    ghostty = {
      enable = true;
      settings = {
        font-family = "Rec Mono Semicasual";
        theme = "Catppuccin Mocha";
        command = "nu -i";
        scrollback-limit = 1 * 1024 * 1024 * 1024; # 1 GiB per pane
      };
    };
    fastfetch.enable = true;
    lazygit.enable = true;
    wezterm = {
      enable = true;
      extraConfig = builtins.readFile ./wezterm.lua;
    };
  };
  services = {
    ssh-agent.enable = true;
  };
}
