{
  pkgs,
  config,
  lib,
  ...
}:

let
  dracula-konsole = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "dracula-konsole";
    version = "2022-03-21";
    name = "${pname}-${version}";
    src = pkgs.fetchFromGitHub {
      owner = "dracula";
      repo = "konsole";
      rev = "030486c75f12853e9d922b59eb37c25aea4f66f4";
      hash = "sha512-gSP3My3B3uHqE8JMnGr3A0RkIqxDykc4Qyzv9g6vUFLukkWayEIDBb6NmJ5FV76ucYCeDfJ17R/kICQPJr/ORQ==";
    };
    installPhase = ''
      mkdir $out
      install -m 0644 "${src}/Dracula.colorscheme" "$out/${pname}.colorscheme"
    '';
  };
in
{
  xdg.configFile."systemd/user/app-org.fcitx.Fcitx5@autostart.service".source =
    config.lib.file.mkOutOfStoreSymlink "/dev/null";
  programs.plasma = {
    enable = true;
    workspace = {
      clickItemTo = "open";
      lookAndFeel = "org.kde.breezedark.desktop";
    };
    kwin = {
      virtualDesktops.number = 2;
    };
    configFile."kwinrc"."Wayland" = {
      "InputMethod" = {
        value = "fcitx5-wayland-launcher.desktop";
        shellExpand = true;
      };
      VirtualKeyboardEnabled = true;
    };
    panels = [
      {
        floating = true;
        height = 40;
        extraSettings = builtins.readFile ./panel.js;
      }
    ];
  };
  home.packages = [
    pkgs.nerd-fonts.symbols-only
    pkgs.recursive
    pkgs.cascadia-code
  ];
  fonts.fontconfig.enable = true;
  programs.konsole = {
    enable = true;
    customColorSchemes = {
      "dracula-konsole" = "${dracula-konsole}/dracula-konsole.colorscheme";
    };
    defaultProfile = "nu";
    extraConfig = {
      FileLocation = {
        scrollbackUseCacheLocation = false;
        scrollbackUseSystemLocation = true;
      };
      MainWindow = {
        MenuBar = "Disabled";
      };
    };
    profiles = lib.genAttrs [ "fish" "nu" ] (
      shell:
      {
        font.name = "Rec Mono SemiCasual";
        font.size = 11;
        colorScheme = "dracula-konsole";
        extraConfig = {
          Scrolling.HistoryMode = 2;
          "Interaction Options" = {
            ColorFilterEnabled = false;
          };
        };
      }
      // {
        command = "${shell} -i";
      }
    );
  };
}
