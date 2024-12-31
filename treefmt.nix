{ ... }:

{
  projectRootFile = "flake.nix";
  programs = {
    nixfmt.enable = true;
  };
  settings.formatter = {
    nixfmt.options = [ "-s" ];
  };
}
