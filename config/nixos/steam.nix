{ pkgs, config, ... }:
let
  buildFHSEnv = pkgs.mylib.buildFHSEnvPrivate;
in
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    package = pkgs.steam.override { inherit buildFHSEnv; };
    extraPackages = with pkgs; [ mangohud ];
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  hardware.steam-hardware.enable = true;
  environment.systemPackages = [ (pkgs.heroic.override { steam = config.programs.steam.package; }) ];
}
