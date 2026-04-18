{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    extraPackages = with pkgs; [ kdePackages.breeze ];
    package = pkgs.wrapPrivateHome {
      id = "com.valvesoftware.Steam";
      devices = [
        "dri"
        "input"
        "ntsync"
      ];
      x11 = true;
      dbus = {
        owns = [ "com.steampowered.*" ];
        talks = [
          "org.freedesktop.Notifications"
          "org.freedesktop.ScreenSaver"
          "org.freedesktop.PowerManagement"
          "org.kde.StatusNotifierWatcher"
        ];
      };
      extraBinds = [ ''"$HOME/.local/share/Steam"'' ];
      extraSetup = ''
        mkdir -p "$HOME/.local/share/Steam"
      '';
    } pkgs.steam;
  };
  hardware.steam-hardware.enable = true;
}
