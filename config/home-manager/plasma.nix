{
  pkgs,
  config,
  lib,
  ...
}:

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
      virtualDesktops.rows = 1;
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
    shortcuts = {
      "services/org.kde.konsole.desktop"."_launch" = [ ];
      "services/org.wezfurlong.wezterm.desktop"."_launch" = "Ctrl+Alt+T";
    };
  };
  home.packages = [
    pkgs.nerd-fonts.symbols-only
    pkgs.recursive
    pkgs.cascadia-code
  ];
  fonts.fontconfig.enable = true;
  programs.konsole = {
    enable = true;
    customColorSchemes =
      # lib.concatMapAttrs
      #   (k: v: { ${lib.removeSuffix ".colorscheme" k} = "${pkgs.iterm2-color-schemes}/konsole/${k}"; })
      #   (
      #     lib.filterAttrs (k: v: lib.hasSuffix ".colorscheme" k) (
      #       builtins.readDir "${pkgs.iterm2-color-schemes}/konsole"
      #     )
      #   );
      lib.genAttrs [ "tokyonight" "Banana Blueberry" ] (
        color: "${pkgs.iterm2-color-schemes}/konsole/${color}.colorscheme"
      );
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
        font.size = 12;
        colorScheme = "tokyonight";
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
