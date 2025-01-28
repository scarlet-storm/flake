{
  lib,
  config,
  pkgs,
  homeManagerConfig,
  secrets,
  ...
}:

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
  sops.age.keyFile = lib.mkForce "${config.home.homeDirectory}/.local/share/sops-nix/key.txt";
  programs.plasma.workspace.wallpaper = "${f3KanataIdolized}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "166,100,160";
  sops.secrets."services/syncthing/devices/aqours/key" = {
    sopsFile = secrets."violet@aqours";
  };
  sops.secrets."services/syncthing/devices/aqours/cert" = {
    sopsFile = secrets."violet@aqours";
  };
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
  programs.mangohud = {
    enable = true;
    settings = {
      procmem = true;
    };
  };
  home.stateVersion = "24.05";
}
