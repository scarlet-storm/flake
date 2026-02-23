# Applications enabled when window manager / DE is configured
{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = {
    programs = {
      ghostty = {
        enable = true;
        settings = {
          font-family = "Rec Mono Semicasual";
          theme = "Catppuccin Mocha";
          command = "nu -i";
          scrollback-limit = 1 * 1024 * 1024 * 1024; # 1 GiB per pane
          window-inherit-working-directory = false;
        };
        package =
          if config.targets.genericLinux.enable then config.lib.nixGL.wrap pkgs.ghostty else pkgs.ghostty;
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
      }
      // lib.optionalAttrs config.targets.genericLinux.enable {
        package = config.lib.nixGL.wrap pkgs.mpv;
      };
    };
  };
in
{
  config = lib.mkIf (config.home.desktopEnvironment != null) cfg;
}
