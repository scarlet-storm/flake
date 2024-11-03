{
  ...
}:

{
  # Wifi using systemd-networkd ??
  networking.networkmanager.enable = false;
  systemd.network.enable = true;
  systemd.network.networks = {
    "10-lan" = {
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
    "20-wifi" = {
      matchConfig.Type = "wlan";
      matchConfig.WLANInterfaceType = "station";
      networkConfig = {
        DHCP = "ipv4";
        DNSOverTLS = "no";
        IPv6LinkLocalAddressGenerationMode = "stable-privacy";
        IPv6PrivacyExtensions = "yes";
        IPv6AcceptRA = "yes";
        IPv4ReversePathFilter = "strict";
        IgnoreCarrierLoss = "10s";
      };
      dhcpV4Config = {
        Anonymize = "yes";
      };
    };
  };
  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    General = {
      EnableNetworkConfiguration = false;
      AddressRandomization = "network";
      AddressRandomizationRange = "full";
      ManagementFrameProtection = 2;
    };
    Network = {
      EnableIPv6 = false;
    };
    DriverQuirks = {
      PowerSaveDisable = "ath10k*,ath12k*";
    };
  };
}
