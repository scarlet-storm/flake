{ pkgs, ... }:
{
  users.users.nixremote = {
    isSystemUser = true;
    group = "nixremote";
    shell = pkgs.bashInteractive;
  };
  users.groups.nixremote = { };

  nix.settings.trusted-users = [ "nixremote" ];
}
