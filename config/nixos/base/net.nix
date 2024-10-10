{
  lib,
  pkgs,
  config,
  name,
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
      llmnr = "false";
      extraConfig = ''
        MulticastDNS=false
      '';
      fallbackDns = [ ];
      dnsovertls = "true";
      dnssec = "false";
      domains = [ "~." ];
    };
  };
  sops.secrets."net/dns-sni" = {
    reloadUnits = [ "systemd-resolved.service" ];
  };
  sops.templates."nameservers.conf" = {
    content = ''
      [Resolve]
      DNS=${
        builtins.concatStringsSep " " (
          builtins.map (ns: ns + "#${name}-" + config.sops.placeholder."net/dns-sni") nameservers
        )
      }
    '';
    path = "/etc/systemd/resolved.conf.d/10-nameservers.conf";
    group = "systemd-resolve";
    mode = "0440";
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
