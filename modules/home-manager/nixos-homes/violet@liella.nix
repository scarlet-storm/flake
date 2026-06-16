{ inputs, ... }: { pkgs, ... }: {
  imports = [
    inputs.self.homeModules.mixins.users.violet
    inputs.self.homeModules.mixins.plasma
  ];
  services.syncthing.enable = true;
  programs.plasma.workspace.wallpaper = "${pkgs.wallpapers.sifas.cards.pShizukuIdolized}";
  programs.plasma.configFile.kdeglobals.General.AccentColor = "1,183,237";
  home.stateVersion = "24.05";
}
