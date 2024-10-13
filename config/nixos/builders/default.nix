{
  imports = [
    ./machines.nix
  ];
  nix = {
    extraOptions = ''
      builders-use-substitutes = true
    '';
    distributedBuilds = true;
  };
}
