{ lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      virglrenderer = prev.virglrenderer.overrideAttrs (previousAttrs: {
        version = "20250203";
        src = prev.fetchFromGitLab {
          owner = "virgl";
          repo = "virglrenderer";
          domain = "gitlab.freedesktop.org";
          rev = "72fbdfb165dc1c64a4ddf5c1f79a63ec9c27c817";
          hash = "sha256-EfYc5BeV9YQuaaKSsDSnQxM2u2Mh4VGmr6NeExc35PQ=";
        };
        mesonFlags = previousAttrs.mesonFlags ++ [
          (lib.mesonBool "venus" true)
          (lib.mesonBool "minigbm_allocation" true)
        ];
        buildInputs = previousAttrs.buildInputs ++ [ prev.vulkan-loader ];
        nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [
          prev.vulkan-headers
          prev.python3Packages.pyyaml
        ];
      });
      procps = prev.procps.overrideAttrs { meta.priority = 9; };
    })
  ];
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "steam"
      "steam-unwrapped"
      "steam-run"
      "nvidia-x11"
      "nvidia-settings"
    ];
}
