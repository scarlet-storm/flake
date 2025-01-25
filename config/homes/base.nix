{ pkgs, ... }:
{
  programs = {
    starship.enable = true;
    fish.enable = true;
    autojump.enable = true;
    atuin.enable = true;
    ssh = {
      enable = true;
      controlMaster = "auto";
      serverAliveInterval = 20;
      serverAliveCountMax = 6;
      controlPath = "\${XDG_RUNTIME_DIR}/ssh-control/mux.%C";
      controlPersist = "10m";
    };
    man.generateCaches = true;
    nushell = {
      enable = true;
      configFile.source = ./config.nu;
    };
  };
  home.packages = (
    with pkgs;
    [
      kopia
      fastfetch
    ]
  );
  home.sessionVariables = {
    EDITOR = "vim";
  };
  systemd.user = {
    tmpfiles.rules = [ "D %t/ssh-control - - - - -" ];
    startServices = "sd-switch";
  };
  nix.gc = {
    automatic = true;
    frequency = "weekly";
    randomizedDelaySec = "1d";
    options = "--delete-older-than 7d";
  };
}
