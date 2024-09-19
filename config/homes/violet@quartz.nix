{
  homeManagerModules,
  pkgs,
  lib,
  ...
}:
let
  pSetsuUnidolized2x = pkgs.fetchurl {
    url = "https://i.idol.st/u/card/art/2x/503UR-Yuki-Setsuna-Here-s-one-for-you-Jet-Black-Wizard-9FIsqL.png";
    sha512 = "3dq72q0v3xvj1hajyr6sia3b6y656mmsn0f326a4y25xl6pzzdi5vw4i7h5zai7xs0gagyhjlmp9h88wqi693fwniljaydjrh8py4ly";
  };
in
{
  imports = [
    ./violet.nix
    homeManagerModules.plasma
  ];
  home.stateVersion = "24.05";
  programs.plasma.workspace.wallpaper = "${pSetsuUnidolized2x}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "216,28,47";
}
