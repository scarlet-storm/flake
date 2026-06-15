{
  pkgs,
  lib,
  config,
  ...
}:
let
  lgConfig = pkgs.writers.writeYAML "zed-lg-config" {
    os = {
      editPreset = "zed";
    };
  };
in
{
  config = lib.mkIf (config.home.desktopEnvironment != null) {
    programs.lazygit.enable = true;
    # symlink zed to zeditor
    home.packages = [
      (pkgs.runCommandLocal "zed-symlink" { } ''
        mkdir -p $out/bin
        ln -s "${config.programs.zed-editor.package}/bin/zeditor" "$out/bin/zed"
      '')
    ];
    programs.zed-editor = {
      enable = true;
      package =
        if config.targets.genericLinux.enable then
          config.lib.nixGL.wrap pkgs.zed-editor
        else
          pkgs.zed-editor;
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
          dark = "Rosé Pine";
        };
        disable_ai = lib.mkDefault true;
        buffer_font_family = "Rec Mono Semicasual";
        buffer_font_size = 16;
        load_direnv = "direct";
        ui_font_size = 16;
        use_system_path_prompts = false;
        vim_mode = true;
      };
      userTasks = [
        {
          label = "lazygit";
          command = "lazygit";
          args = [ "--use-config-file=${lgConfig}" ];
          allow_concurrent_runs = false;
          hide = "on_success";
          reveal = "always";
          reveal_target = "center";
          use_new_terminal = false;
        }
      ];
      userKeymaps = [
        {
          context = "Editor && vim_mode == normal && vim_operator == none && !VimWaiting";
          bindings = {
            "space g g" = [
              "task::Spawn"
              {
                task_name = "lazygit";
                reveal_target = "center";
              }
            ];
          };
        }
      ];
      mutableUserSettings = true;
      mutableUserTasks = true;
      mutableUserKeymaps = true;
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
    };
  };
}
