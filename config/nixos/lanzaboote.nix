{
  inputs,
  ...
}:

{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    (
      { pkgs, lib, ... }:
      {
        environment.systemPackages = [ pkgs.sbsigntool ];
        boot.loader.systemd-boot.enable = lib.mkForce false;
        boot.loader.supportsInitrdSecrets = lib.mkForce true;
        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/efi-keys";
        };
      }
    )
  ];
}
