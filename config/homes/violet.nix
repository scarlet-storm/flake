{
  config,
  lib,
  pkgs,
  ...
}:

let
  username = "violet";
in
# imgbrd-grabber = pkgs.imgbrd-grabber.overrideAttrs (prevAttrs: {
#   version = "2024-09-04";
#   src = pkgs.fetchFromGitHub {
#     owner = "Bionus";
#     repo = "imgbrd-grabber";
#     rev = "4e28e10411fd5ec78a03c9930e1c5671630cf23b";
#     hash = "sha256-8uXqlCXOJf9ynIJVkxwuNTu25p/hTH5jgOoc56JtVa0=";
#     fetchSubmodules = true;
#   };
#   buildInputs = prevAttrs.buildInputs ++ [ pkgs.kdePackages.qtwayland ];
# });
{
  imports = [
    ./common.nix
  ];
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };
  home.packages =
    let
    in
    # input-leap-qt6 = pkgs.input-leap.overrideAttrs rec {
    #   version = "2024-07-27";
    #   src = pkgs.fetchFromGitHub {
    #     owner = "input-leap";
    #     repo = "input-leap";
    #     rev = "67116aba9b6ea946144eb7c417f7374fc2cd7a42";
    #     sha256 = "1hs5wknzb4sxg9xayyxfk9nqzhswvil9wsf76s8xwg0fhry68p07";
    #   };
    #   cmakeFlags = [
    #     "-DINPUTLEAP_REVISION=${builtins.substring 0 8 src.rev}"
    #     "-DINPUTLEAP_BUILD_LIBEI=ON"
    #     "-DINPUTLEAP_USE_EXTERNAL_GTEST=ON"
    #     "-DQT_DEFAULT_MAJOR_VERSION=6"
    #   ];
    #   nativeBuildInputs = with pkgs; [
    #     pkg-config
    #     cmake
    #     kdePackages.wrapQtAppsHook
    #     kdePackages.qttools
    #     gtest
    #   ];
    #   buildInputs = with pkgs; [
    #     curl
    #     avahi-compat
    #     kdePackages.qtbase
    #     libei
    #     libportal
    #     kdePackages.qt5compat
    #     xorg.libX11
    #     xorg.libXinerama
    #     xorg.libXrandr
    #     xorg.libICE
    #     xorg.libSM
    #     ghc_filesystem
    #   ];
    # };
    (with pkgs; [
      kopia
      keepassxc
      fastfetch
      lazygit
      sops
      signal-desktop
      gdu
      nixd
      nixfmt-rfc-style
    ]);

  home.file = {
    ".kopiaignore".text = ''
      /.var
      /.cache
      /Downloads
    '';
  };
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs = {
    fish.enable = true;
    starship.enable = true;
    emacs = {
      enable = true;
      package = pkgs.emacs30-pgtk;
    };
  };
  services = {
    emacs.enable = true;
    emacs.client.enable = true;
    emacs.startWithUserSession = "graphical";
  };
  systemd.user = {
    tmpfiles.rules = [
      "D %t/ssh-control - - - - -"
    ];
  };
}
