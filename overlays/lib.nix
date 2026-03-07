{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      mylib = rec {
        wrapPrefix = (
          prefix: pkg:
          let
            wrapped = pkgs.symlinkJoin {
              inherit (pkg) name pname version;
              paths = [
                (pkgs.runCommandLocal "${pkg.name}-wrapped" { } ''
                  mkdir -p $out/bin
                  for bin in ${pkg}/bin/*; do
                    execName=$(basename $bin)
                    cat <<EOF > $out/bin/$execName
                  #! ${pkgs.runtimeShell}
                  exec ${prefix} ${pkg}/bin/$execName "\$@"
                  EOF
                    chmod a+x $out/bin/$execName
                  done
                  if grep -ar ${pkg} "${pkg}/share/" "${pkg}/lib/systemd"; then
                    echo "Store path in desktop file / systemd unit ?"
                    exit 5
                  fi
                '')
                pkg
              ];
            };
          in
          pkg
          // wrapped
          // {
            override = args: (wrapPrefix prefix (pkg.override args));
            overrideAttrs = abort "not implemented";
          }
        );
        wrapPrivateHome =
          {
            id,
            dbus ? { }, # dbus-proxy args
            extraBinds ? [ ], # rw bind mounts
            roBinds ? [ ], # ro bind mounts
            devices ? [ ], # devices
            audio ? true,
            display ? true,
            x11 ? false,
          }:
          let
            dbusProxyArgs = {
              talks = lib.concatStringsSep " " (map (x: "--talk=${x}") (dbus.talks or [ ]));
              owns = lib.concatStringsSep " " (map (x: "--own=${x}") (dbus.owns or [ ] ++ [ id ])); # apparently flatpak's behaviour is to allow ownership for the id https://docs.flatpak.org/en/latest/sandbox-permissions.html
              sees = lib.concatStringsSep " " (map (x: "--see=${x}") (dbus.sees or [ ]));
              calls = lib.concatStringsSep " " (map (x: "--call=${x}") (dbus.calls or [ ]));
              broadcasts = lib.concatStringsSep " " (map (x: "--broadcast=${x}") (dbus.broadcasts or [ ]));
            };
            bindFlags = lib.concatStringsSep " " (map (x: "-p BindPaths=${x}") extraBinds);
            roBindFlags = lib.concatStringsSep " " (map (x: "-p BindReadOnlyPaths=${x}") roBinds);
            deviceArgs = {
              # flatpak inspired
              dri = "-p BindPaths=-/dev/dri -p DeviceAllow='/dev/dri rw'";
              input = "-p BindPaths=-/dev/input -p DeviceAllow='/dev/input rw' -p BindPaths=-/dev/uinput -p DeviceAllow='/dev/uinput rw'";
            };
            deviceFlags = lib.concatStringsSep " " (map (dev: deviceArgs.${dev}) devices);
            displayFlags = lib.concatStringsSep " " (
              lib.optionals display [
                "-p BindPaths=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
                "-p BindReadOnlyPaths=-$HOME/.config/dconf"
                "-p Environment=NIXOS_OZONE_WL=1"
              ]
            );
            xFlags = lib.concatStringsSep " " (
              lib.optionals x11 [
                "-p BindReadOnlyPaths=-$XAUTHORITY"
                "-p BindPaths=-/tmp/.X11-unix"
                "-p BindPaths=/dev/shm"
                # I don't really know if this should be based on dri flag or x11 flag, but opengl doesn't work without this KEKW
                "-p BindPaths=-/dev/nvidiactl -p DeviceAllow='/dev/nvidiactl rw'"
                "-p BindPaths=-/dev/nvidia-modeset -p DeviceAllow='/dev/nvidia-modeset rw'"
                "-p BindPaths=-/dev/nvidia-uvm -p DeviceAllow='/dev/nvidia-uvm rw'"
                "-p BindPaths=-/dev/nvidia-uvm-tools -p DeviceAllow='/dev/nvidia-uvm-tools rw'"
                "-p BindPaths=-/dev/nvidia0 -p DeviceAllow='/dev/nvidia0 rw'"
              ]
            );
            audioFlags = lib.concatStringsSep " " (
              lib.optionals audio [
                "-p BindPaths=-$XDG_RUNTIME_DIR/pipewire-0"
                "-p BindPaths=-$XDG_RUNTIME_DIR/pulse"
              ]
            );
            init = pkgs.writeShellScript "private-script-${id}" (
              with dbusProxyArgs;
              ''
                set -eu
                mkdir -p "$HOME/.var/nixapps/${id}"
                READY_PIPE="$XDG_RUNTIME_DIR/proxy-ready-$$"
                PROXY_DIR="$XDG_RUNTIME_DIR/proxy-$$"
                mkfifo "$READY_PIPE"
                systemd-run --unit "xdg-dbus-proxy-$$" --user -p RuntimeDirectory="proxy-$$" \
                  --description="DBUS socket for ${id}" --collect \
                  ${pkgs.runtimeShell} -c "exec ${pkgs.xdg-dbus-proxy}/bin/xdg-dbus-proxy --fd=3 \"$DBUS_SESSION_BUS_ADDRESS\" \"$PROXY_DIR/bus\" \
                    --filter ${owns} ${talks} ${sees} ${calls} ${broadcasts} 3>\"$READY_PIPE\""
                exec 4<> "$READY_PIPE"
                read -t 10 -n 1 <&4 || {
                  echo "Error: Proxy failed to initialize"
                  systemctl --user stop xdg-dbus-proxy-$$ || :
                  rm -f "$READY_PIPE"
                  exit 1
                }
                echo "Proxy ready"
                set +e
                systemd-run --unit "app-${id}-$$" --slice app.slice --pty --pipe --user --wait \
                  -p ExitType=cgroup --working-directory=$HOME -p ProtectHome=tmpfs \
                  -p PrivateDevices=true -p PrivateTmp=true -p PrivatePIDs=true --collect\
                  -p BindPaths=$HOME/.var/nixapps/${id}:$HOME -p BindPaths="$PROXY_DIR/bus:$XDG_RUNTIME_DIR/bus" \
                  ${displayFlags} ${audioFlags} ${xFlags} \
                  ${bindFlags} \
                  ${roBindFlags} \
                  ${deviceFlags} \
                  "$@"
                EXIT_CODE=$?
                exit $EXIT_CODE
              ''
            );
          in
          wrapPrefix init;
      };
    })
  ];
}
