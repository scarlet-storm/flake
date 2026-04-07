{
  lib,
  fetchFromGitHub,
  buildGoModule,
  systemd,
  pciutils,
  pkgconf,
  pipewire,
  withNvidia ? false,
  nvidiaPackage ? null,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "OpenLinkHub";
  version = "0.8.2";
  env = {
    CGO_CFLAGS_ALLOW = "-fno-strict-overflow";
  };
  src = fetchFromGitHub {
    owner = "jurkovic-nikola";
    repo = "OpenLinkHub";
    rev = finalAttrs.version;
    hash = "sha256-uOu9cdsqKdI15Nkl9/WnVqU+NIdyeec66aUTYl02zY4=";
  };
  vendorHash = "sha256-ibR0F2b5mgNsi/aq1f3FO0lJTJrGt5zePv5dpuu9HCo=";
  nativeBuildInputs = [
    makeWrapper
    pkgconf
  ];
  buildInputs = [
    systemd
    pipewire
  ];
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
})
