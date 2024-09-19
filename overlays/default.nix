{ lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (
        kfinal: kprev: {
          powerdevil = kprev.powerdevil.overrideAttrs (previousAttrs: {
            buildInputs = previousAttrs.buildInputs ++ [ prev.ddcutil ];
          });
          plasma-desktop = kprev.plasma-desktop.overrideAttrs (previousAttrs: {
            buildInputs = builtins.filter (x: x.pname != "ibus") previousAttrs.buildInputs;
          });
        }
      );
    })
    (final: prev: {
      libportal = prev.libportal.overrideAttrs (previousAttrs: {
        version = "20240704";
        src = prev.fetchFromGitHub {
          owner = "flatpak";
          repo = "libportal";
          rev = "a1530a98db296a8f3c501932d68a7d008da2ac2e";
          hash = "sha256-40pFuHO/aYj8bkjT1VxZImcdq0ZJjhCAtBWPrEvt6Ik=";
        };
        mesonFlags = previousAttrs.mesonFlags ++ [ (lib.mesonEnable "backend-qt6" false) ];
      });
    })
    (final: prev: {
      intel-vaapi-driver =
        (prev.intel-vaapi-driver.overrideAttrs (previousAttrs: {
          nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [ prev.autoPatchelfHook ];
          appendRunpaths = lib.makeLibraryPath [ prev.mesa.drivers ];
          src = prev.fetchFromGitHub {
            owner = "intel";
            repo = "intel-vaapi-driver";
            rev = "4206d0e15363d188f30f2f3dbcc212fef206fc1d";
            hash = "sha256-kbasiVOz9eHbO87SEuVMDT2pK5ouiVGglL+wcFJH9IM=";
          };
        })).override
          { enableHybridCodec = true; };
    })
  ];
}
