{ lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (
        kfinal: kprev: {
          powerdevil = kprev.powerdevil.overrideAttrs (previousAttrs: {
            buildInputs = previousAttrs.buildInputs ++ [ prev.ddcutil ];
          });
        }
      );
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
      procps = prev.procps.overrideAttrs {
        meta.priority = 9;
      };
    })

    # (final: prev: {
    #   intel-vaapi-driver =
    #     (prev.intel-vaapi-driver.overrideAttrs (previousAttrs: {
    #       nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ prev.autoPatchelfHook ];
    #       appendRunpaths = lib.makeLibraryPath [ prev.mesa.drivers ];
    #       src = prev.fetchFromGitHub {
    #         owner = "intel";
    #         repo = "intel-vaapi-driver";
    #         rev = "4206d0e15363d188f30f2f3dbcc212fef206fc1d";
    #         hash = "sha256-kbasiVOz9eHbO87SEuVMDT2pK5ouiVGglL+wcFJH9IM=";
    #       };
    #     })).override
    #       { enableHybridCodec = true; };
    # })
  ];
}
