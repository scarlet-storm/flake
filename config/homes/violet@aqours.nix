{ pkgs, homeManagerConfig, ... }:

let
  f3KanataIdolized = pkgs.fetchurl {
    url = "https://i.idol.st/u/card/art/2x/857UR-Konoe-Kanata-Like-This-And-There-Alluring-Renowned-Actress-vN37YQ.png";
    hash = "sha512-G0NO8yLslZSpUWXremb08d/vX+OajYV1K5eRM5ULs8MBblKJbn5NLUfzLHME2DUwtSSJ4lGNvB8vO01FTloKSA==";
  };
in
{
  imports = [
    ./violet.nix
    homeManagerConfig.plasma
  ];
  programs.plasma.workspace.wallpaper = "${f3KanataIdolized}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "166,100,160";
  services.syncthing.enable = true;
  home.stateVersion = "24.05";
}
