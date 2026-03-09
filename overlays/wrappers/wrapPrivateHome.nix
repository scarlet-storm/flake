{
  lib,
  wrapPrefix,
  writeShellScript,
  coreutils,
  xdg-dbus-proxy,
}:
{
  id,
  dbus ? { }, # dbus-proxy args
  extraBinds ? [ ], # rw bind mounts
  roBinds ? [ ], # ro bind mounts
  devices ? [ ], # devices
  audio ? true,
  display ? true,
  x11 ? false,
  extraSetup ? "",
  extraArgs ? [ ],
}:
let
  dbusProxyArgs = {
    talks = lib.concatStringsSep " " (map (x: "--talk=${x}") (dbus.talks or [ ]));
    owns = lib.concatStringsSep " " (map (x: "--own=${x}") (dbus.owns or [ ] ++ [ "${id}.*" ])); # apparently flatpak's behaviour is to allow ownership for the id https://docs.flatpak.org/en/latest/sandbox-permissions.html
    sees = lib.concatStringsSep " " (map (x: "--see=${x}") (dbus.sees or [ ]));
    calls = lib.concatStringsSep " " (
      map (x: "--call=${x}") (dbus.calls or [ ] ++ [ "org.freedesktop.portal.*=*" ]) # default flatpak permissions
    );
    broadcasts = lib.concatStringsSep " " (
      map (x: "--broadcast=${x}") (
        dbus.broadcasts or [ ] ++ [ "org.freedesktop.portal.*=@/org/freedesktop/portal/*" ]
      )
    );
  };
  bindFlags = lib.concatStringsSep " " (map (x: "-p BindPaths=${x}") extraBinds);
  roBindFlags = lib.concatStringsSep " " (map (x: "-p BindReadOnlyPaths=${x}") roBinds);
  deviceArgs = {
    # flatpak inspired
    dri = lib.concatStringsSep " " [
      "-p BindPaths=-/dev/dri -p DeviceAllow='/dev/dri rw'"
      "-p BindPaths=-/dev/nvidiactl -p DeviceAllow='/dev/nvidiactl rw'"
      "-p BindPaths=-/dev/nvidia-modeset -p DeviceAllow='/dev/nvidia-modeset rw'"
      "-p BindPaths=-/dev/nvidia-uvm -p DeviceAllow='/dev/nvidia-uvm rw'"
      "-p BindPaths=-/dev/nvidia-uvm-tools -p DeviceAllow='/dev/nvidia-uvm-tools rw'"
      "-p BindPaths=-/dev/nvidia0 -p DeviceAllow='/dev/nvidia0 rw'"
    ];
    input = "-p BindPaths=-/dev/input -p DeviceAllow='/dev/input rw' -p BindPaths=-/dev/uinput -p DeviceAllow='/dev/uinput rw'";
  };
  deviceFlags = lib.concatStringsSep " " (map (dev: deviceArgs.${dev}) devices);
  displayFlags = lib.concatStringsSep " " (
    lib.optionals display [
      "-p BindPaths=$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
      "-p Environment=NIXOS_OZONE_WL=1"
    ]
  );
  xFlags = lib.concatStringsSep " " (
    lib.optionals x11 [
      "-p BindReadOnlyPaths=-$XAUTHORITY"
      "-p BindPaths=-/tmp/.X11-unix"
      "-p BindPaths=/dev/shm"
    ]
  );
  audioFlags = lib.concatStringsSep " " (
    lib.optionals audio [
      "-p BindPaths=-$XDG_RUNTIME_DIR/pipewire-0"
      "-p BindPaths=-$XDG_RUNTIME_DIR/pulse"
    ]
  );
  proxy-init = writeShellScript "proxy-init-${id}" (
    with dbusProxyArgs;
    ''
      set -eu
      ${coreutils}/bin/cat <<EOF > /.flatpak-info
      [Application]
      name=${id}

      [Instance]
      instance-id=$INSTANCE_ID
      EOF
      echo "{\"child-pid\": $$}" > "$XDG_RUNTIME_DIR/.flatpak/$INSTANCE_ID/bwrapinfo.json"
      exec ${xdg-dbus-proxy}/bin/xdg-dbus-proxy --fd=3 "$@" \
      --filter ${owns} ${talks} ${sees} ${calls} ${broadcasts} 3>"$READY_PIPE"
    ''
  );
  init = writeShellScript "private-script-${id}" ''
    set -eu
    mkdir -p "$HOME/.var/nixapps/${id}"
    ${extraSetup}
    READY_PIPE="$XDG_RUNTIME_DIR/proxy-ready-$$"
    PROXY_DIR="$XDG_RUNTIME_DIR/proxy-$$"

    INSTANCE_ID=$(uuidgen | tr -d "-")

    mkfifo "$READY_PIPE"
    systemd-run --unit "xdg-dbus-proxy-$$" --user --collect --description="DBUS socket for ${id}" -p Type=exec \
      -p RuntimeDirectory="proxy-$$" -p RuntimeDirectory=.flatpak/$INSTANCE_ID \
      -p Environment="INSTANCE_ID=$INSTANCE_ID" -p Environment="READY_PIPE=$READY_PIPE" \
      -p TemporaryFileSystem=/ -p BindReadOnlyPaths=/nix -p ProtectHome=tmpfs -p BindPaths=$XDG_RUNTIME_DIR \
      ${proxy-init} "$DBUS_SESSION_BUS_ADDRESS" "$PROXY_DIR/bus"

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
      -p ExitType=cgroup --working-directory=$HOME -p ProtectHome=tmpfs -p Type=exec \
      -p TemporaryFileSystem=/ -p BindPaths=/run -p BindReadOnlyPaths=/etc \
      -p BindReadOnlyPaths=/nix -p BindReadOnlyPaths=/usr -p TemporaryFileSystem=$XDG_RUNTIME_DIR \
      -p PrivateDevices=true -p PrivateTmp=true -p PrivatePIDs=true --collect -p Environment=NIXOS_XDG_OPEN_USE_PORTAL=1 \
      -p BindPaths=$HOME/.var/nixapps/${id}:$HOME -p BindPaths="$PROXY_DIR/bus:$XDG_RUNTIME_DIR/bus" \
      ${displayFlags} ${audioFlags} ${xFlags} \
      ${bindFlags} \
      ${roBindFlags} \
      ${deviceFlags} ${lib.concatStringsSep " " extraArgs} \
      "$@"
    EXIT_CODE=$?
    exit $EXIT_CODE
  '';
in
wrapPrefix init
