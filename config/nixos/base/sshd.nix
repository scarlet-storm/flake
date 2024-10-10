{ ... }:
let
  trustedUserCAFile = "trustedUserCA";
in
{
  environment.etc."ssh/${trustedUserCAFile}".text = ''
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAION8+4aF6hbXO1QxU5GqvZZHZWThD6MAiLcWq+bPSWD8 Gwen User CA
  '';
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        TrustedUserCAKeys = "/etc/ssh/trustedUserCA";
      };
      hostKeys = [
        {
          bits = 4096;
          path = "/var/lib/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/var/lib/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
