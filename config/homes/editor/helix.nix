{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    extraConfig = builtins.readFile "${(pkgs.formats.toml { }).generate "helix-config" {
      theme = "nyxvamp-obsidian";
    }}";
  };
}
