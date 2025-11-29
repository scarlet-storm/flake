{
  pkgs,
  lib,
  homeManagerConfig,
  ...
}:
let
  username = "violet";
in
{
  imports = [
    ./base.nix
    ./rclone.nix
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
    (pkgs.zed-editor.fhsWithPackages (pkgs: [
      pkgs.go
      pkgs.python3
      pkgs.unzip # unzip lsp downloads by extensions
      # shared libraries for dynamically linked lanugage servers
      (lib.getLib pkgs.openssl)
    ]))
  ]
  ++ (with pkgs; [
    deskflow
    kopia
    keepassxc
    sops
    signal-desktop
    nixd
    nil
    nixfmt-rfc-style
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
    emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages =
        epkgs:
        (with epkgs; [
          vterm
          treesit-grammars.with-all-grammars
        ])
        ++ (with pkgs; [
          ripgrep
          fd
          # treemacs
          python3
        ]);
    };
    mpv = {
      enable = true;
      config = {
        cache = "yes";
        demuxer-max-bytes = "2GiB";
        vo = "gpu-next,gpu,dmabuf-wayland";
        gpu-api = "vulkan";
        hwdec = "vulkan,nvdec,vaapi";
      };
    };
    ghostty = {
      enable = true;
      settings = {
        font-family = "Rec Mono Semicasual";
        theme = "Everblush";
        command = "nu -i";
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
    emacs.enable = true;
    emacs.client.enable = true;
    emacs.startWithUserSession = "graphical";
    ssh-agent.enable = true;
  };
}
