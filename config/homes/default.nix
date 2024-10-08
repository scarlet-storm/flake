{ lib, ... }:
{
  # home-manager as nixos module
  nixos = lib.genAttrs [
    "violet@quartz"
    "violet@liella"
  ] (home: ./${home}.nix);
  # standalone homeManagerConfigurations
  standalone =
    lib.genAttrs
      [
        "violet@marchenstar"
      ]
      (home: {
        system = "x86_64-linux";
        config = ./${home}.nix;
      });
}
