{
  lib,
  pkgs,
  ...
}:

let
  f1Kanata2x = pkgs.fetchurl {
    url = "https://i.idol.st/u/card/art/2x/186Konoe-Kanata-It-s-my-turn-next-UR-92PePZ.png";
    hash = "sha256-ZsE61EBIXGQBVP899LObmB75no3UA+Ic6aborT4zUJU=";
  };
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
      wallpaper = lib.mkDefault "${f1Kanata2x}";
    };
    configFile.kdeglobals = {
      General.AccentColor = lib.mkDefault "166,100,160";
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
        colorScheme = "catppuccin-mocha";
        extraConfig = {
          Scrolling.HistoryMode = 2;
        };
      };
    };
  };
}
