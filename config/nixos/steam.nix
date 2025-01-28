{ pkgs, modules, ... }:

{
  imports = [ modules.nixos.unfree ];
  unfree.packageList = [
    "steam"
    "steam-unwrapped"
    "steam-original"
    "steam-run"
  ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    package = pkgs.steam.override {
      buildFHSEnv = (
        p:
        pkgs.buildFHSEnvBubblewrap (
          p
          // {
            PrivateTmp = true;
            unshareCgroup = true;
            unsharePid = true;
            extraBwrapArgs = p.extraBwrapArgs ++ [
              "--tmpfs /home"
              "--bind \$HOME/.var/apps \$HOME"
              "--bind \$HOME/Downloads \$HOME/Downloads"
              "--ro-bind \$HOME/.config/dconf \$HOME/.config/dconf"
              "--ro-bind \$HOME/.config/xsettingsd \$HOME/.config/xsettingsd"
              # https://github.com/ValveSoftware/steam-for-linux/issues/10808 ???
              "--ro-bind /run/current-system/sw/share/icons /usr/share/icons"
              "--chdir \$HOME"
            ];
          }
        )
      );
      extraEnv = {
        MANGOHUD = true;
      };
    };
    extraPackages = with pkgs; [ mangohud ];
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  hardware.steam-hardware.enable = true;
}
