{
  config,
  lib,
  pkgs,
  ...
}:

{
  users.users.violet = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    linger = false;
    uid = 1000;
    shell = pkgs.fish;
    group = "violet";
    hashedPassword = "$y$j9T$YqczB6qWWMIpzBcdJufNV/$gR6lcas0ujW1NMqfZCXqrDfntk/exD2oLTAnSHGhCB3";
  };
  users.groups.violet = {
    gid = 1000;
  };
}
