{
  pkgs,
  homeManagerConfig,
  ...
}:

let
  f1Kanata2x = pkgs.fetchurl {
    url = "https://i.idol.st/u/card/art/2x/186Konoe-Kanata-It-s-my-turn-next-UR-92PePZ.png";
    hash = "sha256-ZsE61EBIXGQBVP899LObmB75no3UA+Ic6aborT4zUJU=";
  };
in
{
  imports = [
    ./violet.nix
    homeManagerConfig.plasma
  ];
  programs.plasma.workspace.wallpaper = "${f1Kanata2x}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "166,100,160";
  services.syncthing.enable = true;
  home.packages = [
    (pkgs.zed-editor.fhsWithPackages (pkgs: [ pkgs.go ]))
  ];
  home.stateVersion = "24.05";
}
