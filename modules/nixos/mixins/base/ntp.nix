{ lib, ... }:

let
  ntsServers = [
    "time.cloudflare.com"
    # "nts.netnod.net"
    # "any.time.nl"
  ];
in
{
  # Use chrony instead of timesyncd
  services.timesyncd.enable = false;
  services.chrony.enable = true;
  services.chrony.extraFlags = [
    "-F"
    "1"
  ];
  services.chrony.extraConfig =
    (lib.strings.concatMapStringsSep "\n" (server: "server ${server} iburst nts") ntsServers)
    + ''

      nocerttimecheck 1
    '';
}
