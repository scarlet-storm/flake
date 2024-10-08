{
  secrets,
  ...
}:
let
  ageKeyFile = "/var/lib/sops-nix/key.txt";
in
{
  sops.defaultSopsFile = secrets.common;
  sops.age.sshKeyPaths = [ ];
  sops.gnupg.sshKeyPaths = [ ];
  sops.age.keyFile = ageKeyFile;
  sops.age.generateKey = true;
}
