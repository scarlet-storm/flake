{ lib, ... }:

{
  imports = [ ./lib.nix ];
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "steam"
      "steam-unwrapped"
      "steam-run"
      "nvidia-x11"
      "nvidia-settings"
      "hplip"
    ];
}
