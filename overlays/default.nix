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
      libportal = prev.libportal.overrideAttrs (previousAttrs: rec {
        version = "0.8.1";
        src = prev.fetchFromGitHub {
          owner = "flatpak";
          repo = "libportal";
          rev = "${version}";
          hash = "sha256-NAkD5pAQpmAtVxsFZt74PwURv+RbGBfqENIwyxEEUSc=";
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
