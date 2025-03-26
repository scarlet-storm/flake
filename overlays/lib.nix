{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      mylib = rec {
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
            -p ExitType=cgroup --working-directory=\$HOME -p ProtectHome=tmpfs -p BindPaths=\$HOME/.var/nixapps/${id}:\$HOME \
            -p BindReadOnlyPaths=\$HOME/.config/dconf -p BindPaths=\$XDG_RUNTIME_DIR -p BindPaths=\$HOME/Downloads -p PrivatePIDs=true -p PrivateTmp=true'');
        buildFHSEnvPrivate = (
          p:
          pkgs.buildFHSEnvBubblewrap (
            p
            // {
              PrivateTmp = true;
              unshareCgroup = true;
              unsharePid = true;
              extraBwrapArgs = (lib.attrByPath [ "extraBwrapArgs" ] [ ] p) ++ [
                "--tmpfs /home"
                "--bind \$HOME/.var/nixapps/steam \$HOME"
                "--bind \$HOME/Downloads \$HOME/Downloads"
                "--ro-bind \$HOME/.config/dconf \$HOME/.config/dconf"
                "--ro-bind \$HOME/.config/xsettingsd \$HOME/.config/xsettingsd"
                # https://github.com/ValveSoftware/steam-for-linux/issues/10808 ???
                "--ro-bind /run/current-system/sw/share/icons /usr/share/icons"
                "--chdir \$HOME"
              ];
            }
          )
        );
      };
    })
  ];
}
