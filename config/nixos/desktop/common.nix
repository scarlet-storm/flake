{
  config,
  lib,
  pkgs,
  ...
}:
{
  services = {
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      jack.enable = true;
    };
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    libinput.enable = true;
    flatpak.enable = true;
  };
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    (nerdfonts.override {
      fonts = [
        "CascadiaCode"
        "CascadiaMono"
      ];
    })
  ];
  environment.systemPackages = with pkgs; [
    libva-utils
  ];
  programs = {
    firefox.enable = true;
  };
  security.rtkit.enable = true;
  hardware.i2c.enable = true;
}