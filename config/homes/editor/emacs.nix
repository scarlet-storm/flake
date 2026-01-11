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
    "doom".source = pkgs.symlinkJoin {
      name = "doom-emacs-themes";
      paths = [
        (pkgs.stdenv.mkDerivation {
          name = "rose-pine-doom-emacs";
          src = pkgs.fetchFromGitHub {
            owner = "donniebreve";
            repo = "rose-pine-doom-emacs";
            rev = "78100823087f2fa727cdd5c06f8deb17988520b6";
            hash = "sha256-QcV+f7qxWO5o9p9yusJHVRzxBTiSAhR85HDE4I4fuA4=";
          };
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            make TARGETPATH=$out/themes install
            runHook postInstall
          '';
        })
        ./doom
      ];
    };
  };
}
