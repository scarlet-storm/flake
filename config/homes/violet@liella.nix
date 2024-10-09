{
  pkgs,
  homeManagerConfig,
  ...
}:
let
  f3Eli2x = pkgs.fetchurl {
    url = "https://i.idol.st/u/card/art/2x/655UR-Ayase-Eli-Goodness-Are-You-Getting-Flustered-Relax-and-Refresh-Si3WjZ.png";
    sha512 = "0c93fqy76929pr4w4s233rw159fz003r65w7dmgkqjghfg1wbfracl5a2kizwir6di60dm5xangy7j408k1h66xxgcfh8b0lmhpvqp5";
  };
in
{
  imports = [
    ./violet.nix
    homeManagerConfig.plasma
  ];
  services.syncthing.enable = true;
  home.packages = [
    pkgs.zed-editor
  ];
  programs.plasma.workspace.wallpaper = "${f3Eli2x}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "122,238,255";
  home.stateVersion = "24.05";
}
