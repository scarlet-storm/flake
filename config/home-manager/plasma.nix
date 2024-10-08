{
  lib,
  pkgs,
  ...
}:

let
  catppuccin-konsole = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "catppuccin-konsole";
    version = "2024-07-06";
    src = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "konsole";
      rev = "3b64040e3f4ae5afb2347e7be8a38bc3cd8c73a8";
      hash = "sha256-d5+ygDrNl2qBxZ5Cn4U7d836+ZHz77m6/yxTIANd9BU=";
    };
    installPhase = ''
      cp -avT "${src}/themes" "$out/"
    '';
  };
in
{
  programs.plasma = {
    enable = true;
    workspace = {
      clickItemTo = "open";
      lookAndFeel = "org.kde.breezedark.desktop";
    };
  };
  programs.konsole = {
    enable = true;
    customColorSchemes = lib.genAttrs [
      "catppuccin-mocha"
      "catppuccin-machiato"
    ] (variant: "${catppuccin-konsole}/${variant}.colorscheme");
    defaultProfile = "myProfile";
    extraConfig = {
      FileLocation = {
        scrollbackUseCacheLocation = false;
        scrollbackUseSystemLocation = true;
      };
    };
    profiles = {
      myProfile = {
        font.name = "Cascadia Code";
        font.size = 11;
        colorScheme = "catppuccin-mocha";
        extraConfig = {
          Appearance.BoldIntense = false;
          Scrolling.HistoryMode = 2;
          "Interaction Options" = {
            ColorFilterEnabled = false;
          };
        };
      };
    };
  };
}
