{ pkgs, ... }:
{
  programs = {
    starship.enable = true;
    fish.enable = true;
    ssh = {
      enable = true;
      controlMaster = "auto";
      serverAliveInterval = 20;
      serverAliveCountMax = 6;
      controlPath = "\${XDG_RUNTIME_DIR}/ssh-control/mux.%C";
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
  systemd = {
    user.startServices = "sd-switch";
  };
}
