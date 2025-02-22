# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  pkgs,
  lib,
  config,
  modules,
  inputs,
  ...
}:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
    modules.nixos.sops
    ./ntp.nix
    ./sdboot.nix
    ./sshd.nix
    ./nix-conf.nix
    ./net.nix
  ];
  sops.secrets."users/root/password".neededForUsers = true;
  security.pam.services.systemd-run0 = { };
  users.users.root.hashedPasswordFile = lib.mkDefault config.sops.secrets."users/root/password".path;
  boot = {
    initrd = {
      systemd.enable = true;
      systemd.dbus.enable = true;
      availableKernelModules = [
        "vfat"
        "crc32c-intel"
      ];
    };
    kernel = {
      sysctl = {
        "net.ipv4.tcp_congestion_control" = "bbr";
        # For QUIC
        "net.core.rmem_max" = 8388608;
        "net.core.wmem_max" = 8388608;
      };
    };
    kernelModules = [ "tcp_bbr" ];
    tmp.useTmpfs = true;
  };

  console = {
    keyMap = lib.mkDefault "us";
    useXkbConfig = false;
  };
  time.timeZone = lib.mkDefault "Asia/Kolkata";
  i18n = {
    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "en_IN/UTF-8"
    ];
    defaultLocale = lib.mkDefault "en_IN.UTF-8";
    extraLocaleSettings."LC_TIME" = "en_GB.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    age
    curl
    rsync
    nvme-cli
    e2fsprogs
    efibootmgr
    openssl
    moreutils
    ncdu
    zellij
  ];
  systemd.oomd.enable = lib.mkDefault false;
  programs = {
    fish.enable = true;
    command-not-found.enable = false;
    git.enable = true;
    htop.enable = true;
    vim = {
      enable = true;
      defaultEditor = true;
    };
  };
  users.mutableUsers = false;
  services = {
    fstrim.enable = true;
    locate.package = pkgs.plocate;
    locate.enable = true;
  };

}
