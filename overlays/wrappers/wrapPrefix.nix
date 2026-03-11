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
          if grep -q ${pkg} ${pkg}/share/applications/*.desktop; then
            echo "Replacing store paths in desktop files"
            mkdir -p $out/share
            cp -RLv ${pkg}/share/. $out/share/
            for app in $out/share/applications/*.desktop; do
              substituteInPlace "$app" --replace-fail "${pkg}" "$out"
            done
          fi
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
