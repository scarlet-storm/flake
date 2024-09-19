{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.unfree;
in
{
  options.unfree.packageList = (
    with lib;
    mkOption {
      type = (with types; listOf str);
      description = "
      List of package names to include in unfree predicate
    ";
      default = [ ];
      example = [ "nvidia" ];
    }
  );
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.packageList;
  };
}
