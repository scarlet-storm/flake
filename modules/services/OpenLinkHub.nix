{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.OpenLinkHub;
in
{
  options = {
    services.OpenLinkHub.enable = lib.mkEnableOption "Enable service";
    services.OpenLinkHub.package = lib.mkPackageOption pkgs "OpenLinkHub" { };
  };

  config = lib.mkIf cfg.enable {
    users.users.openlinkhub = {
      isSystemUser = true;
      group = "openlinkhub";
    };
    users.groups.openlinkhub = { };
    systemd.services.OpenLinkHub = {
      description = "icue link service";
      enable = true;
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = "openlinkhub";
        Group = "openlinkhub";
        ConfigurationDirectory = "OpenLinkHub";
        ExecStartPre = [
          "${pkgs.coreutils}/bin/cp -urv --no-preserve=mode ${cfg.package}/share/OpenLinkHub/database /etc/OpenLinkHub/"
          "${pkgs.coreutils}/bin/ln -sf ${cfg.package}/share/OpenLinkHub/web ${cfg.package}/share/OpenLinkHub/static /etc/OpenLinkHub"
        ];
        ExecStart = "${cfg.package}/bin/OpenLinkHub";
        NoNewPrivileges = true;
        PrivateTmp = true;
        RestrictSUIDSGID = true;
      };
    };
    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b1c", MODE="0600", OWNER="openlinkhub"
    '';
  };
}
