{ pkgs, lib, ... }:

{
  imports = [ ./common.nix ];
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      Users = {
        MinimumUid = 1000;
        MaximumUid = 60513;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    xsettingsd
    kdePackages.sddm-kcm
    kdePackages.ksvg
    kdePackages.skanlite
    kdePackages.plasma-vault
    libreoffice-qt6-fresh
    unar # ark rar plugin
  ];
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  programs.kdeconnect.enable = true;
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5 = {
      waylandFrontend = true;
      addons = [ pkgs.fcitx5-mozc ];
    };
  };
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
    xwaylandvideobridge
    krdp
  ];
}
