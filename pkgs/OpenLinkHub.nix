{
  lib,
  fetchFromGitHub,
  buildGoModule,
  systemd,
  pciutils,
  withNvidia ? false,
  nvidiaPackage ? null,
  makeWrapper,
}:

buildGoModule rec {
  pname = "OpenLinkHub";
  version = "0.4.3";
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "jurkovic-nikola";
    repo = "OpenLinkHub";
    rev = "${version}";
    hash = "sha512-RmI7reDFAkSDkLQ5siCgWxBlJaNfWmYGpB7PCKRK1mOHz7svnlwZMK6P8zmPIxMYRhXrpz0Pz8VapbqHnubqzg==";
  };
  vendorHash = "sha256-o+Ek5pJG4fjeQg8e11afAbVIvzmDvG92v2mp4yOM3x4=";
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ systemd ];
  postInstall = ''
    mkdir -p $out/share/OpenLinkHub
    touch $out/share/OpenLinkHub/atomic
    cp -rv database static web $out/share/OpenLinkHub
    wrapProgram $out/bin/OpenLinkHub \
      --chdir $out/share/OpenLinkHub \
      --suffix PATH : ${
        lib.makeBinPath (
          [
            pciutils
          ]
          ++ lib.optional withNvidia nvidiaPackage
        )
      };
  '';
}
