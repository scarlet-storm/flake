{
  config,
  lib,
  pkgs,
  modules,
  inputs,
  name,
  homes,
  ...
}:

let
  users = [ "violet" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./net.nix
    inputs.lix-module.nixosModules.default
    modules.nixos.builders
    modules.nixos.hardware.intel
    modules.nixos.hardware.gpu.intel
    modules.nixos.hardware.gpu.nvidia
    modules.nixos.lanzaboote
    modules.nixos.home-manager
    modules.nixos.desktop.plasma
    modules.nixos.steam
  ] ++ builtins.map (user: modules.nixos.users.${user}) users;
  home-manager.users = lib.genAttrs users (user: homes."${user}@${name}");
  hardware.nvidia.prime = {
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };
  system.stateVersion = "24.11";
  services = {
    sunshine = {
      autoStart = true;
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
