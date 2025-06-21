{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Disable aliased packages
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "auto-allocate-uids"
        "cgroups"
      ];
      auto-allocate-uids = true;
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      randomizedDelaySec = "1d";
      options = "--delete-older-than 15d";
    };
    channel.enable = false;
  };
}
