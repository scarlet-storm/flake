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
          mkdir -p "$out/share/applications"
          for bin in ${pkg}/bin/*; do
            execName=$(basename $bin)
            cat <<EOF > $out/bin/$execName
          #! ${runtimeShell}
          exec ${prefix} ${pkg}/bin/$execName "\$@"
          EOF
            chmod a+x $out/bin/$execName
          done
          for app in ${pkg}/share/applications/*.desktop; do
            appName=$(basename $app)
            dest="$out/share/applications/$appName"
            cp -av "$app" "$dest"
            if grep -q "${pkg}" $dest ; then
              echo "Replacing store path in $dest"
              substituteInPlace "$dest" --replace-fail "${pkg}" "$out"
            fi
          done
          if grep -qar ${pkg} "${pkg}/lib/systemd"; then
            echo "Store path in systemd unit ?"
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
