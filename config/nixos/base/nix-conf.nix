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
      options = "--delete-older-than 14d";
    };
    channel.enable = false;
  };
  system.switch = {
    enable = false;
    enableNg = true;
  };
}
