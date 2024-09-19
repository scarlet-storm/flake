{ lib, ... }:
{
  # home-manager as nixos module
  nixos = lib.genAttrs [
    "violet@quartz"
  ] (home: ./homes/${home}.nix);
  standalone = lib.genAttrs [
    "violet@marchenstar"
  ] (home: ./homes/${home}.nix);
}
