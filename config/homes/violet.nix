{
  pkgs,
  homeManagerConfig,
  ...
}:

let
  username = "violet";
in
{
  imports = [
    ./base.nix
    homeManagerConfig.firefox
  ];
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };
  home.packages =
    let
      input-leap-qt6 = pkgs.input-leap.overrideAttrs rec {
        pname = "input-leap";
        version = "3.0.2";
        name = "${pname}-${version}";
        src = pkgs.fetchFromGitHub {
          owner = "input-leap";
          repo = "input-leap";
          rev = "7e5889dc6fc907a0dd218d94623378cc53417cb2";
          hash = "sha512-IshXGnDI6DfSeUnyofpeBtClwbmlqVATO0WNhzKDAGvWh5LDOk0wQQMHDGen6PYjP40kUas8mhejMVnvRcmIpQ==";
        };
        cmakeFlags = [
          "-DINPUTLEAP_REVISION=${builtins.substring 0 8 src.rev}"
          "-DINPUTLEAP_BUILD_LIBEI=ON"
          "-DINPUTLEAP_USE_EXTERNAL_GTEST=ON"
          "-DQT_DEFAULT_MAJOR_VERSION=6"
        ];
        nativeBuildInputs = with pkgs; [
          pkg-config
          cmake
          kdePackages.wrapQtAppsHook
          kdePackages.qttools
          gtest
        ];
        buildInputs = with pkgs; [
          curl
          avahi-compat
          libei
          libportal
          kdePackages.qtbase
          kdePackages.qt5compat
          kdePackages.qtwayland
          xorg.libX11
          xorg.libXinerama
          xorg.libXrandr
          xorg.libICE
          xorg.libSM
          ghc_filesystem
        ];
      };
      imgbrd-grabber-head = pkgs.imgbrd-grabber.overrideAttrs (prevAttrs: {
        version = "2024-10-14";
        src = pkgs.fetchFromGitHub {
          owner = "Bionus";
          repo = "imgbrd-grabber";
          rev = "73f6cc01b5e85eda925b945dbc8afa4746839ad2";
          hash = "sha512-8Ls7IBDkM2uVekrYv/zg+PQe7VCb3zGbspcMRosAIYxm3kTUR8YgNnjsI0QxKhYjs7MEU9pDd7MUsekUQLCAAw==";
          fetchSubmodules = true;
        };
        buildInputs = prevAttrs.buildInputs ++ [ pkgs.kdePackages.qtwayland ];
      });
    in
    [
      input-leap-qt6
      imgbrd-grabber-head
    ]
    ++ (with pkgs; [
      kopia
      keepassxc
      fastfetch
      lazygit
      sops
      signal-desktop
      gdu
      nixd
      nixfmt-rfc-style
      ripgrep
      yubikey-manager
    ]);
  home.file = {
    ".kopiaignore".text = ''
      /.var
      /.cache
      /Downloads
    '';
  };

  programs = {
    fish.enable = true;
    starship.enable = true;
    emacs = {
      enable = true;
      package = pkgs.emacs30-pgtk;
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
  };
  services = {
    emacs.enable = true;
    emacs.client.enable = true;
    emacs.startWithUserSession = "graphical";
    ssh-agent.enable = true;
  };
}
