{
  imports = [
    ./cloud.nix
  ];
  nix = {

    extraOptions = ''
      builders-use-substitutes = true
    '';
    distributedBuilds = true;
  };
}
