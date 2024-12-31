{ pkgs, ... }:
{
  programs = {
    starship.enable = true;
    fish.enable = true;
    nushell.enable = true;
    autojump.enable = true;
    ssh = {
      enable = true;
      controlMaster = "auto";
      serverAliveInterval = 20;
      serverAliveCountMax = 6;
      controlPath = "\${XDG_RUNTIME_DIR}/ssh-control/mux.%C";
      controlPersist = "10m";
    };
    man.generateCaches = true;
  };
  home.packages = (
    with pkgs;
    [
      kopia
      fastfetch
      age
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
