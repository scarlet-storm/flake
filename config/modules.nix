{
  nixos = {
    base = ./nixos/base;
    builders = ./nixos/builders;
    hardware = {
      intel = ./nixos/hardware/intel.nix;
      amd = ./nixos/hardware/amd.nix;
      gpu.intel = ./nixos/hardware/gpu-intel.nix;
      gpu.nvidia = ./nixos/hardware/gpu-nvidia.nix;
    };
    users.violet = ./nixos/users/violet.nix;
    lanzaboote = ./nixos/lanzaboote.nix;
    home-manager = ./nixos/home-manager.nix;
    unfree = ./nixos/unfree.nix;
    steam = ./nixos/steam.nix;
    desktop.plasma = ./nixos/desktop/plasma.nix;
  };
  home-manager = {
    "generic" = ./home-manager/generic.nix;
    "plasma" = ./home-manager/plasma.nix;
  };
}
