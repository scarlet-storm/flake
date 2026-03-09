{
  symlinkJoin,
  runCommandLocal,
  runtimeShell,
}:
let
  buildWrapped =
    prefix: pkg:
    symlinkJoin {
      inherit (pkg) name pname version;
      paths = [
        (runCommandLocal "${pkg.name}-wrapped" { } ''
          mkdir -p $out/bin
          for bin in ${pkg}/bin/*; do
            execName=$(basename $bin)
            cat <<EOF > $out/bin/$execName
          #! ${runtimeShell}
          exec ${prefix} ${pkg}/bin/$execName "\$@"
          EOF
            chmod a+x $out/bin/$execName
          done
          if grep -qar ${pkg} "${pkg}/share/" "${pkg}/lib/systemd"; then
            echo "Store path in desktop file / systemd unit ?"
            exit 5
          fi
        '')
        pkg
      ];
    };
  wrapPrefix =
    prefix: pkg:
    pkg
    // (buildWrapped prefix pkg)
    // {
      override = args: (wrapPrefix prefix (pkg.override args));
      overrideAttrs = abort "not implemented";
    };
in
wrapPrefix
