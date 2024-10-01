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
          publicKeyFile = "/var/lib/efi-keys/db.cert.pem";
          privateKeyFile = "/var/lib/efi-keys/db.key.pem";
        };
      }
    )
  ];
}
