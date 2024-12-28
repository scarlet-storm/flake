{
  pkgs,
  homeManagerConfig,
  ...
}:
let
  pShizuku2x = pkgs.fetchurl {
    url = "https://i.idol.st/u/card/art/2x/831UR-Osaka-Shizuku-That-s-So-Cute-Briar-Rose-nf1fKb.png";
    sha512 = "sha512-Y04vU1Cw9l0otEQbB9G7XM2Dn8FI+nIlM8oubt3Y6yXGZH98smz+0qVtMzTV57iCuAqesDFYHtuWrZBHbIPsJw==";
  };
in
{
  imports = [
    ./violet.nix
    homeManagerConfig.plasma
  ];
  services.syncthing.enable = true;
  programs.plasma.workspace.wallpaper = "${pShizuku2x}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "1,183,237";
  home.stateVersion = "24.05";
}
