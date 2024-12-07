{
  pkgs,
  homeManagerConfig,
  ...
}:

let
  username = "violet";
in
{
  imports = [
    ./base.nix
    homeManagerConfig.firefox
  ];
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
  };
  home.packages =
    let
      imgbrd-grabber-head = pkgs.imgbrd-grabber.overrideAttrs (prevAttrs: {
        version = "2024-10-14";
        src = pkgs.fetchFromGitHub {
          owner = "Bionus";
          repo = "imgbrd-grabber";
          rev = "73f6cc01b5e85eda925b945dbc8afa4746839ad2";
          hash = "sha512-8Ls7IBDkM2uVekrYv/zg+PQe7VCb3zGbspcMRosAIYxm3kTUR8YgNnjsI0QxKhYjs7MEU9pDd7MUsekUQLCAAw==";
          fetchSubmodules = true;
        };
        buildInputs = prevAttrs.buildInputs ++ [ pkgs.kdePackages.qtwayland ];
      });

      # TODO: /run socket restrictions
      discord-wrapped = (
        pkgs.runCommand "discord-wrapped"
          {
            meta.priority = -1;
            preferLocalBuild = true;
          }
          ''
            mkdir -p $out/bin
            cat <<EOF > $out/bin/Discord
            #! ${pkgs.runtimeShell} -e
            systemd-run --unit app-discord@\$(uuidgen).service --slice app.slice --pty --pipe --user \
            -p ExitType=cgroup --working-directory=\$HOME -p ProtectHome=tmpfs -p BindPaths=\$HOME/.var/apps/:\$HOME \
            -p BindPaths=\$XDG_RUNTIME_DIR ${pkgs.discord}/bin/Discord
            EOF
            chmod a+x $out/bin/Discord
          ''
      );
    in
    [
      imgbrd-grabber-head
      discord-wrapped
      pkgs.discord
    ]
    ++ (with pkgs; [
      input-leap
      kopia
      keepassxc
      sops
      signal-desktop
      gdu
      nixd
      nixfmt-rfc-style
      yubikey-manager
    ]);
  home.file = {
    ".kopiaignore".text = ''
      /.var
      /.cache
      /Downloads
    '';
  };

  programs = {
    emacs = {
      enable = true;
      package = pkgs.emacs30-pgtk;
    };
    mpv = {
      enable = true;
      config = {
        cache = "yes";
        demuxer-max-bytes = "2GiB";
        vo = "gpu-next,gpu,dmabuf-wayland";
        gpu-api = "vulkan";
        hwdec = "vulkan,nvdec,vaapi";
      };
    };
    fastfetch.enable = true;
    lazygit.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
    fzf.enable = true;
  };
  services = {
    emacs.enable = true;
    emacs.client.enable = true;
    emacs.startWithUserSession = "graphical";
    ssh-agent.enable = true;
  };
}
