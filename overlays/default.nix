{ lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      virglrenderer = prev.virglrenderer.overrideAttrs (previousAttrs: {
        mesonFlags = previousAttrs.mesonFlags ++ [
          (lib.mesonBool "venus" true)
          (lib.mesonBool "minigbm_allocation" true)
        ];
        buildInputs = previousAttrs.buildInputs ++ [ prev.vulkan-loader ];
        nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ prev.vulkan-headers ];
      });
      procps = prev.procps.overrideAttrs { meta.priority = 9; };
    })
  ];
}
