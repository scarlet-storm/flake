{
  ...
}:

{
  nix.buildMachines = [
    {
      hostName = "static.79.160.181.135.clients.your-server.de";
      sshUser = "nixremote";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      speedFactor = 20;
    }
  ];
}
