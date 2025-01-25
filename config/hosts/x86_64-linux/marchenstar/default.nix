{
  lib,
  pkgs,
  modules,
  inputs,
  secrets,
  ...
}:
let
  users = [ "kanata" ];
in

{
  imports = [
    ./hardware-configuration.nix
    ./net.nix
    inputs.sops-nix.nixosModules.sops
    modules.nixos.hardware.intel
    modules.nixos.lanzaboote.default
    modules.nixos.home-manager
    modules.nixos.users.kanata
    inputs.disko.nixosModules.default
    ./fs.nix
    inputs.self.nixosModules.services.hath
  ] ++ builtins.map (user: modules.nixos.users.${user}) users;
  home-manager.users = lib.genAttrs users (user: modules.homes."${user}");
  hardware.rasdaemon.enable = true;
  services.smartd.enable = true;
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_GB.UTF-8";
  sops.secrets."users/root/password" = {
    sopsFile = secrets.marchenstar;
  };
  services = {
    sysstat.enable = true;
    hath.enable = true;
  };
  system.stateVersion = "25.05";
}
