{ lib, ... }:

{
  nixpkgs.overlays = [
    (
      final: prev:
      {
        virglrenderer = prev.virglrenderer.overrideAttrs (previousAttrs: {
          mesonFlags = previousAttrs.mesonFlags ++ [
            (lib.mesonBool "venus" true)
            (lib.mesonBool "minigbm_allocation" true)
          ];
          buildInputs = previousAttrs.buildInputs ++ [
            prev.vulkan-loader
            prev.vulkan-headers
          ];
        });
        libvirt = prev.libvirt.override {
          enableXen = false;
          enableZfs = false;
        };
        procps = prev.procps.overrideAttrs {
          meta.priority = 9;
        };
      }
      // lib.genAttrs [ "mozc" "fcitx5-mozc" ] (
        drv:
        prev.${drv}.overrideAttrs (
          previousAttrs:
          (lib.optionalAttrs
            (
              builtins.compareVersions previousAttrs.version "2.30.5544.102" <= 0
              && lib.strings.hasPrefix "gcc" prev.stdenv.cc.name
              && builtins.compareVersions prev.stdenv.cc.version "14.0" >= 0
            )
            {
              env.NIX_CFLAGS_COMPILE = "-Wno-error=maybe-uninitialized";
            }
          )
        )
      )
    )
  ];
}
