{
  pkgs,
  homeManagerConfig,
  ...
}:

let
  f3KanataIdolized = pkgs.fetchurl {
    url = "https://i.idol.st/u/card/art/xKXpzBUR-Konoe-Kanata-Like-This-And-There-Alluring-Renowned-Actress-ubVzTH.jpeg";
    hash = "sha512-CKCSFIeWNglvXMLG3LF++CaUPNqTJIrc3YsWlM+FMBCiGkOuLd2TJC44KnHHX/Ak3C4T3exTW+lNEDMgoJseBg==";
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
  home.packages = [
    (pkgs.zed-editor.fhsWithPackages (pkgs: [ pkgs.go ]))
  ];
  home.stateVersion = "24.05";
}
