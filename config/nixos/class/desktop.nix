{ ... }:
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
    })
  ];
}
