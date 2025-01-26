{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.hath;
in
{
  options = {
    services.hath.enable = lib.mkEnableOption "Enable hath service";
    services.hath.package = lib.mkPackageOption pkgs "hentai-at-home" { };
  };

  config = lib.mkIf cfg.enable (
    let
      homeDir = "/var/lib/hath";
    in
    {
      users.users.hath = {
        isSystemUser = true;
        group = "hath";
        home = "${homeDir}";
        createHome = false;
        uid = 690;
      };
      users.groups.hath = {
        gid = 690;
      };
      systemd.services.hath = {
        description = "hath service";
        enable = true;
        unitConfig = {
          RequiresMountsFor = "${homeDir}";
        };
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "${homeDir}";
          User = "hath";
          Group = "hath";
          LoadCredential = "client_login:${config.sops.secrets."services/hath/client_login".path}";
          ExecStartPre = ''${pkgs.coreutils}/bin/cp -fv "''${CREDENTIALS_DIRECTORY}/client_login" "${homeDir}/data/client_login"'';
          ExecStart = "${cfg.package}/bin/HentaiAtHome";
          Restart = "on-failure";
          RestartSec = "5m";
          NoNewPrivileges = true;
          PrivateTmp = true;
          RestrictSUIDSGID = true;
          LogFilterPatterns = "~Code=(200|400|403|404|301)";
          BindPaths = "${homeDir}";
          BindReadOnlyPaths = "/etc/resolv.conf";
          Nice = "-10";
        };
        confinement = {
          enable = true;
          packages = [ config.i18n.glibcLocales ];
        };
      };
      networking.firewall.allowedTCPPorts = [ 9443 ];
      sops.secrets."services/hath/client_login" = {
        restartUnits = [ "hath.service" ];
      };
    }
  );
}
