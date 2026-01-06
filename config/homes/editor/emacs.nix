{ pkgs, ... }:
{
  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages =
        epkgs:
        (with epkgs; [
          treesit-grammars.with-all-grammars
          vterm
        ])
        ++ (with pkgs; [
          fd
          pandoc
          ripgrep
          shfmt
          shellcheck
          python3Packages.grip
        ]);
    };
  };
  services.emacs = {
    enable = true;
    client.enable = true;
    startWithUserSession = "graphical";
  };
  xdg.configFile = {
    "doom".source = ./doom;
  };
}
