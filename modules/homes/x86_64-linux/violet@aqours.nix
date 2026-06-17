{ inputs, ... }:
{
  lib,
  config,
  pkgs,
  ...
}:
let
  sopsFile = inputs.self + "/secrets/violet.yaml";
in
{
  imports = [
    inputs.self.homeModules.mixins.users.violet
    inputs.self.homeModules.mixins.plasma
  ];
  sops.age.keyFile = lib.mkForce "${config.home.homeDirectory}/.local/share/sops-nix/key.txt";
  programs.plasma.workspace.wallpaper = "${pkgs.wallpapers.sifas.cards.f1KanataIdolized}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "166,100,160";
  sops.secrets."services/syncthing/devices/aqours/key" = { inherit sopsFile; };
  sops.secrets."services/syncthing/devices/aqours/cert" = { inherit sopsFile; };
  services.syncthing = {
    enable = true;
    key = config.sops.secrets."services/syncthing/devices/aqours/key".path;
    cert = config.sops.secrets."services/syncthing/devices/aqours/cert".path;
    # extraOptions = [ ];
    overrideDevices = true;
    overrideFolders = true;
    # passwordFile = null;
    settings = {
      options = {
        natEnabled = false;
      };
      devices = {
        aqours = {
          id = "W5X4XBK-AXVMYLS-2GIP5DO-VL6V3DB-SOIRMKM-JWAIUUO-U2AFGOT-BNYK3QH";
        };
        ruby = {
          id = "TEOSCW7-LCY4KQ3-RYLG63K-AA724QG-27G7RMS-M5NKUNY-MXUSJTZ-AO3CMAE";
        };
      };
      folders = {
        "default" = {
          label = "Default Folder";
          path = "~/Sync";
          type = "sendreceive";
          versioning = {
            type = "staggered";
            params = {
              maxAge = builtins.toString (60 * 60 * 24 * 365);
            };
          };
          devices = [ "ruby" ];
        };
      };
    };
  };
  home.stateVersion = "24.05";
}
