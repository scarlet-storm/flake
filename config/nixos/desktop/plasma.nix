{ pkgs, ... }:

{
  imports = [
    ./common.nix
  ];
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  environment.systemPackages = with pkgs; [
    xsettingsd
    kdePackages.sddm-kcm
    kdePackages.ksvg
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
}
