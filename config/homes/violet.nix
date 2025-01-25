{
  pkgs,
  lib,
  homeManagerConfig,
  ...
}:

let
  username = "violet";
  wrapPrefix = (
    prefix:
    {
      pkg,
      execName,
      postBuild ? "",
      ...
    }:
    pkgs.symlinkJoin {
      inherit (pkg) name pname version;
      inherit postBuild;
      paths = [
        (pkgs.runCommandLocal "${execName}-wrapped"
          {

          }
          ''
            mkdir -p $out/bin
            cat <<EOF > $out/bin/${execName}
            #! ${pkgs.runtimeShell}
            exec ${prefix} ${pkg}/bin/${execName} \$@
            EOF
            chmod a+x $out/bin/${execName}
          ''
        )
        pkg
      ];
    }
  );
  # TODO: /run socket restrictions
  wrapPrivateHome =
    id:
    (wrapPrefix ''
      systemd-run --unit app-${id}@\$(${pkgs.util-linux}/bin/uuidgen).service --slice app.slice --pty --pipe --user \
      -p ExitType=cgroup --working-directory=\$HOME -p ProtectHome=tmpfs -p BindPaths=\$HOME/.var/apps/:\$HOME \
      -p BindPaths=\$XDG_RUNTIME_DIR'');
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
  nixpkgs.config.allowUnfreePredicate = (pkg: builtins.elem (lib.getName pkg) [ "discord" ]);
  news.display = "silent";
  home.packages =
    let
      imgbrd-grabber-git = pkgs.imgbrd-grabber.overrideAttrs (prevAttrs: {
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

    in
    [
      imgbrd-grabber-git
      (wrapPrivateHome "Discord" {
        pkg = pkgs.discord;
        execName = "Discord";
        # why in **** hell is there two binaries ???
        postBuild = "rm -fv $out/bin/discord";
      })
      (pkgs.zed-editor.fhsWithPackages (pkgs: [
        pkgs.go
        pkgs.python3
        pkgs.unzip # unzip lsp downloads by extensions
        # shared libraries for dynamically linked lanugage servers
        (lib.getLib pkgs.openssl)
      ]))
    ]
    ++ (with pkgs; [
      input-leap
      kopia
      keepassxc
      sops
      signal-desktop
      nixd
      nil
      nixfmt-rfc-style
      yubikey-manager
      virt-viewer
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
