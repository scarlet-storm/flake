{
  lib,
  ...
}:

let
  ntsServers = [
    "time.cloudflare.com"
    "nts.netnod.se"
    # "ntp.miuku.net"
  ];
in
{
  # Use chrony instead of timesyncd
  services.timesyncd.enable = false;
  services.chrony.enable = true;
  services.chrony.extraConfig = lib.strings.concatMapStringsSep "\n" (
    server: "server ${server} iburst nts"
  ) ntsServers;
}
