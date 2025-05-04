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
  version = "0.5.5";
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "jurkovic-nikola";
    repo = "OpenLinkHub";
    rev = "${version}";
    hash = "sha256-xcP/Ze9Ba0uYzjCvcx3awij2zA7O8Iu1nbEd/mfeS0w=";
  };
  vendorHash = "sha256-1GVNyCyurUurO8cteX4msh+eHuAzS7/GqMV4sGV3Wno=";
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
