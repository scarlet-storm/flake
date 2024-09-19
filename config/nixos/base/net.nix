{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Disable default network scripts
  networking.useDHCP = false;
  services = {
    resolved.enable = true;
    resolved.llmnr = "false";
    resolved.extraConfig = ''
      MulticastDNS=false
    '';
  };
  networking.nftables.enable = true;
  networking.firewall = {
    enable = lib.mkDefault true;
    logRefusedConnections = false;
    checkReversePath = "strict";
    filterForward = true;
  };
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}
