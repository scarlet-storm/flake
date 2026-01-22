{
  pkgs,
  lib,
  config,
  ...
}:
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
          clangStdenv.cc
          clang-tools
        ]);
    };
  };
  services.emacs = {
    enable = true;
    client.enable = true;
    startWithUserSession = "graphical";
  };
  xdg.configFile = {
    doom = {
      source = ./doom;
      recursive = true;
    };
  };
  systemd.user.services =
    let
      doomBinary = "${config.xdg.configHome}/emacs/bin/doom";
    in
    {
      doom-sync = {
        Unit = {
          Description = "Sync emacs config from doom config";
          ConditionFileIsExecutable = doomBinary;
          X-Restart-Triggers = [
            config.programs.emacs.finalPackage
            "${config.xdg.configFile.doom.source}"
          ];
          Before = "emacs.service";
          X-SwitchMethod = "restart";
        };
        Service = {
          Type = "oneshot";
          ExecStart = "${lib.getBin pkgs.systemd}/bin/systemd-cat ${doomBinary} sync -U";
          RemainAfterExit = true;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
