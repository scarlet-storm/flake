{
  pkgs,
  homeManagerConfig,
  ...
}:
let
  f3RikoIdolized2x = pkgs.fetchurl {
    url = "https://i.idol.st/u/card/art/2x/894UR-Sakurauchi-Riko-You-mentioned-you-liked-it-no-A-Fairy-Concert-l5NeuT.png";
    hash = "sha512-frrj8k8ap8Rs8MIyk96TsAJWEG7mw0d477Axgv2ITJe1CsffpEhqP4zPx4jM9uLF3pSdDhMYIzxHmX8u4ztgEQ==";
  };
in
{
  imports = [
    ./violet.nix
    homeManagerConfig.plasma
  ];
  home.stateVersion = "24.05";
  programs.plasma.workspace.wallpaper = "${f3RikoIdolized2x}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "255,158,172";
}
