{
  lib,
  pkgs,
  config,
  systemName,
  ...
}:

let
  nameservers = [
    "2a07:a8c0::"
    "45.90.28.0"
    "45.90.30.0"
    "2a07:a8c1::"
  ];
in
{
  # Disable default network scripts
  networking.useDHCP = false;
  networking.nameservers = [ ];
  services = {
    resolved = {
      enable = true;
      settings.Resolve = {
        FallbackDNS = "";
        LLMNR = false;
        MulticastDNS = false;
        DNSSEC = false;
        DNSOverTLS = true;
        Domains = [ ];
        DNS = [ ];
      };
    };
  };
  sops.secrets."net/dns-sni" = { };
  sops.templates."network.dns" = {
    content = "${builtins.concatStringsSep " " (
      map (ns: ns + "#${systemName}-" + config.sops.placeholder."net/dns-sni") nameservers
    )}";
    reloadUnits = [ "systemd-resolved.service" ];
  };
  systemd.services.systemd-resolved = {
    serviceConfig = {
      LoadCredential = "network.dns:${config.sops.templates."network.dns".path}";
      SetCredential = "network.search_domains:~.";
    };
  };
  networking.nftables.enable = true;
  networking.firewall = {
    enable = lib.mkDefault true;
    logRefusedConnections = false;
    checkReversePath = "strict";
    filterForward = true;
  };
  environment.systemPackages = with pkgs; [ wireguard-tools ];
}
