{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "violet";
in
{
  sops.secrets."users/${name}/password".neededForUsers = true;
  users.users.${name} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ] ++ lib.optional (builtins.hasAttr "libvirtd" config.users.groups) "libvirtd";
    linger = false;
    uid = 1000;
    shell = pkgs.fish;
    group = "${name}";
    hashedPasswordFile = lib.mkDefault config.sops.secrets."users/${name}/password".path;
  };
  users.groups.${name} = {
    gid = 1000;
  };
}
