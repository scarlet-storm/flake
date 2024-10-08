{

  base = ./base;
  builders = ./builders;
  hardware = {
    intel = ./hardware/intel.nix;
    amd = ./hardware/amd.nix;
    gpu.intel = ./hardware/gpu-intel.nix;
    gpu.nvidia = ./hardware/gpu-nvidia.nix;
  };
  users = {
    violet = ./users/violet.nix;
  };
  lanzaboote = ./lanzaboote;
  home-manager = ./home-manager.nix;
  unfree = ./unfree.nix;
  steam = ./steam.nix;
  desktop = {
    common = ./desktop/common.nix;
    plasma = ./desktop/plasma.nix;
  };
  sops = ./sops.nix;
}
