{
  imports = [
    ./emacs.nix
    ./helix.nix
    ./zed.nix
  ];
  programs.helix.defaultEditor = true;
}
