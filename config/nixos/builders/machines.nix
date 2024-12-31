{ lib, ... }:

{
  nix.buildMachines = lib.map (
    host:
    {
      sshUser = "nixremote";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    }
    // {
      hostName = host;
    }
  ) [ ];
}
