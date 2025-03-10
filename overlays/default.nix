{ lib, ... }:

{
  imports = [ ./lib.nix ];
  nixpkgs.overlays = [
    (final: prev: { procps = prev.procps.overrideAttrs { meta.priority = 10; }; })
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
