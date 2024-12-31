{
  config,
  lib,
  pkgs,
  ...
}:
let
  name = "kanata";
in
{
  sops.secrets."users/${name}/password".neededForUsers = true;
  users.users.${name} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
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
