{ ... }:

{
  # Use NetworkManager for wifi, since all devices have GUI
  networking.networkmanager = {
    enable = true;
    # iwd doesn't support mac randomization via NetworkManager
    wifi.backend = "wpa_supplicant";
    wifi.scanRandMacAddress = true;
    wifi.macAddress = "stable";
    wifi.powersave = false;
    connectionConfig = {
      "connection.llmnr" = 0;
      "connection.mdns" = 0;
      "connection.dns-over-tls" = 0;
      "connection.stable-id" = "\${CONNECTION}-\${BOOT}-\${DEVICE}";
      "ipv6.ip6-privacy" = 2;
      "ipv6.addr-gen-mode" = "stable-privacy";
      "ipv4.dhcp-client-id" = "stable";
    };
  };
}
