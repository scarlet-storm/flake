{ pkgs, modules, ... }:

{
  imports = [ modules.nixos.unfree ];
  unfree.packageList = [
    "steam"
    "steam-unwrapped"
    "steam-original"
    "steam-run"
  ];
  programs.steam.enable = true;
  programs.steam.remotePlay.openFirewall = true;
  programs.steam.localNetworkGameTransfers.openFirewall = true;
  hardware.steam-hardware.enable = true;
  programs.steam.package = pkgs.steam.override {
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
  programs.steam.extraPackages = with pkgs; [ mangohud ];
  environment.systemPackages = [ pkgs.bubblewrap ];
}
