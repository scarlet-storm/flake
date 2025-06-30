{
  pkgs,
  lib,
  config,
  ...
}:
let
  rcloneMounts = {
    "ayumu.crypt" = "mnt/crypt";
  };
in
{
  systemd.user.mounts = lib.concatMapAttrs (
    name: path:
    let
      where = "${config.home.homeDirectory}/${path}";
      unitName =
        (import "${pkgs.path}/nixos/lib/utils.nix" {
          inherit config lib;
          pkgs = null;
        }).escapeSystemdPath
          where;
    in
    {
      ${unitName} = {
        Unit = { };
        Mount = {
          What = "${name}:";
          Where = where;
          Type = "rclone";
          Options = "_netdev,vfs-cache-mode=full,vfs-cache-max-age=off,vfs-cache-max-size=100G,links,vfs-fast-fingerprint,syslog";
        };
      };
    }
  ) rcloneMounts;
}
