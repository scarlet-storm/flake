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
    services.OpenLinkHub.package = lib.options.mkOption { };
  };

  config = lib.mkIf cfg.enable (
    let
      homeDir = "/var/lib/OpenLinkHub";
    in
    {
      users.users.openlinkhub = {
        isSystemUser = true;
        group = "openlinkhub";
        home = "${homeDir}";
        createHome = true;
      };
      users.groups.openlinkhub =
        {
        };
      systemd.services.OpenLinkHub = {
        description = "icue link service";
        enable = true;
        wants = [ "network.target" ];
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          WorkingDirectory = "${homeDir}";
          User = "openlinkhub";
          Group = "openlinkhub";
          ExecStartPre = ''${pkgs.bash}/bin/bash -ce "ln -sf ${cfg.package}/share/assets/* ${homeDir}; cp -rnv --dereference --no-preserve=mode ${cfg.package}/share/database ${cfg.package}/share/config.json ${homeDir}"'';
          ExecStart = "${cfg.package}/bin/OpenLinkHub";
          NoNewPrivileges = true;
          PrivateTmp = true;
          RestrictSUIDSGID = true;
        };
      };
      services.udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b1c", MODE="0666"
      '';
    }
  );
}
