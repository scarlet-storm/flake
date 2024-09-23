{ pkgs, ... }:

{
  wrapPrefix =
    prefix: orig-pkg: execName:
    pkgs.symlinkJoin {
      inherit (orig-pkg) name pname version;
      paths = [ orig-pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        mv $out/bin/${execName} $out/bin/${execName}-wrapped
        makeWrapper ${prefix}/bin/${prefix.name} \
                    $out/bin/${execName} \
                    --add-flags $out/bin/${execName}-wrapped
      '';
    };
}
