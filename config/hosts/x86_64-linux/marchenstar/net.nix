{
  config,
  lib,
  secrets,
  ...
}:
{

  networking.networkmanager.enable = false;
  systemd.network.enable = true;
  systemd.network.networks = {
    "10-default" = {
      matchConfig.Type = "ether !wlan";
      networkConfig = {
        DHCP = "ipv4";
        DNSOverTLS = "no";
        IPv6LinkLocalAddressGenerationMode = "stable-privacy";
        IPv6PrivacyExtensions = "yes";
        IPv6AcceptRA = "yes";
        IPv4ReversePathFilter = "strict";
      };
    };
  };
  # sops.secrets."net/yharnam/ipv6" = {
  #   reloadUnits = [
  #     "systemd-networkd.service"
  #     "nftables.service"
  #   ];
  # };
  # sops.templates."yharnam/ipv6" = {
  #   content = lib.generators.toINI { } {
  #     Network = {
  #       Address = "${config.sops.placeholder."net/yharnam/ipv6"}";
  #       Gateway = "fe80::1";
  #     };
  #   };
  #   path = "/etc/systemd/network/${defaultNetwork}.network.d/ipv6.conf";
  #   group = "systemd-network";
  #   mode = "0444";
  # };
  sops.secrets."ssh/initrd_host_key" = {
    sopsFile = secrets.marchenstar;
    mode = "0600";
  };
  boot.initrd = {
    availableKernelModules = [ "r8169" ];
    systemd.network.enable = true;
    systemd.network.networks."10-default" = config.systemd.network.networks."10-default";
    network = {
      enable = true;
      ssh = {
        enable = true;
        extraConfig = ''
          HostKey /etc/ssh/ssh_host_ed25519_key
          AuthorizedKeysFile /etc/ssh/authorized_keys
        '';
        ignoreEmptyHostKeys = true;
        authorizedKeys = [ "" ];
      };
    };
    secrets = {
      "/etc/ssh/ssh_host_ed25519_key" = config.sops.secrets."ssh/initrd_host_key".path;
      "/etc/ssh/authorized_keys" = config.sops.secrets."services/sshd/authorized_keys".path;
    };
  };
}
