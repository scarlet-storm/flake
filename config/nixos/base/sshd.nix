{ config, ... }:
{
  sops.secrets."services/sshd/authorized_keys" = {
    mode = "0444";
  };
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      authorizedKeysFiles = [ config.sops.secrets."services/sshd/authorized_keys".path ];
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
