{
  config,
  lib,
  pkgs,
  ...
}:
let
  # TODO let's make a proper module for this
  name = "violet";
  userRecord = {
    autoResizeMode = "grow";
    disposition = "regular";
    enforcePasswordPolicy = true;
    luksDiscard = true;
    luksOfflineDiscard = false;
    luksExtraMountOptions = "compress-force=zstd,discard=async";
    filesystemType = "btrfs";
    memberOf = [
      "libvirtd"
      "wheel"
    ];
    perMachine = [
      {
        imagePath = "/dev/disk/by-path/pci-0000:02:00.0-nvme-1";
        matchHostname = "aqours";
        storage = "luks";
        shell = "/run/current-system/sw/bin/zsh";
      }
    ];
    preferredSessionLauncher = "plasma";
    preferredSessionType = "wayland";
    privileged = {
      hashedPassword = [ "${config.sops.placeholder."users/${name}/password"}" ];
    };
    realName = "Violet";
    shell = "/usr/bin/zsh";
    userName = "${name}";
  };
in
{
  sops = {
    secrets."users/${name}/password" = {
      neededForUsers = !config.services.homed.enable;
    };
    templates."${name}_user_record".content = ''
      ${lib.generators.toJSON { } userRecord}
    '';
  };
  # systemd.services.systemd-homed-firstboot.serviceConfig = {
  #   LoadCredential = "home.create.${name}:${config.sops.templates."${name}_user_record".path}";
  # };
  users = lib.mkIf (!config.services.homed.enable) {
    users.${name} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ]
      ++ lib.optional (builtins.hasAttr "libvirtd" config.users.groups) "libvirtd";
      linger = false;
      uid = 1000;
      shell = pkgs.zsh;
      group = "${name}";
      hashedPasswordFile = lib.mkDefault config.sops.secrets."users/${name}/password".path;
    };
    groups.${name} = {
      gid = 1000;
    };
  };
  # newuidmap doesn't work if /etc/subuid is a symlink
  systemd.tmpfiles.settings =
    lib.mkIf (config.services.homed.enable && config.virtualisation.podman.enable)
      {
        "90-violet-uidmap" = {
          "/etc/subuid" = {
            "f+~" = {
              user = "root";
              group = "root";
              mode = "0644";
              argument = "dmlvbGV0OjUyNDI4ODo2NTUzNg==";
            };
          };
          "/etc/subgid" = {
            "f+~" = {
              user = "root";
              group = "root";
              mode = "0644";
              argument = "dmlvbGV0OjUyNDI4ODo2NTUzNg==";
            };
          };
        };
      };
}
