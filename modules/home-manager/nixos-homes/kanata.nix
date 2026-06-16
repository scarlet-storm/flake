{ inputs, ... }: { lib, ... }: {
  imports = [ inputs.self.homeModules.mixins.common ];
  home.username = "kanata";

  home.stateVersion = lib.mkDefault "24.11";
}
