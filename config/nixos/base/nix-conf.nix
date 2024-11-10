{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Disable aliased packages
  nixpkgs.config.allowAliases = false;
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
    };
    gc = {
      automatic = true;
      dates = "weekly";
      randomizedDelaySec = "1d";
      options = "--delete-older-than 15d";
    };
    channel.enable = false;
    auto-optimise-store = true;
  };
  system.switch = {
    enable = false;
    enableNg = true;
  };
}
