{ pkgs, lib, ... }:
{
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor;
    extraPackages = with pkgs; [
      lazygit
      # common stuff for some random tools ?
      unzip
    ];
    userSettings = {
      languages = {
        Nix = {
          language_servers = [
            "nixd"
            "!nil"
          ];
        };
        Python = {
          language_servers = [
            "ty"
            "!basedpyright"
            "..."
          ];
        };
      };
      lsp = {
        nixd = {
          settings = {
            formatting = {
              command = [
                "nixfmt"
                "-s"
              ];
            };
          };
        };
      };
      terminal = {
        font_size = 14;
      };
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      theme = {
        mode = "system";
        light = "Tokyo Night Light";
        dark = "Catppuccin Mocha";
      };
      disable_ai = lib.mkDefault true;
      buffer_font_family = "Rec Mono Semicasual";
      buffer_font_size = 16;
      colorize_brackets = true;
      load_direnv = "direct";
      ui_font_size = 16;
      use_system_path_prompts = false;
      vim_mode = true;
    };
    extensions = [
      # themes
      "catppuccin"
      "flexoki-themes"
      "rose-pine-theme"
      "jellybeans-vim"
      "tokyo-night"
      # language
      "elisp"
      "git-firefly"
      "haskell"
      "ini"
      "lua"
      "make"
      "meson"
      "nix"
      "nu"
      "toml"
    ];
    mutableUserSettings = true;
  };
}
