{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  environment.systemPackages = [
    pkgs.sbsigntool
    pkgs.mokutil
  ];
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.supportsInitrdSecrets = lib.mkForce true;
  sops.secrets."efi/db.key.pem" = { };
  boot.lanzaboote = {
    enable = true;
    publicKeyFile = ./db.cert.pem;
    privateKeyFile = config.sops.secrets."efi/db.key.pem".path;
  };
}
