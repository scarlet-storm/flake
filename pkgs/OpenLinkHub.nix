{
  lib,
  fetchFromGitHub,
  buildGoModule,
  systemd,
  emptyDirectory,
  nvidia ? emptyDirectory,
  pciutils,
  makeWrapper,
}:

buildGoModule rec {
  pname = "OpenLinkHub";
  version = "2024-10-27";
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "jurkovic-nikola";
    repo = "OpenLinkHub";
    rev = "b63b9d8ba94c84e8140b46311593430109fc0c35";
    hash = "sha512-vkTTQPDQeUwX8Yz/SRAAu4Zs3sis1kdTYeThIuh77ccXXtbCISu5tRNlsUul4bodznkFk8DGgXBpuHovbHW7CQ==";
  };
  vendorHash = "sha256-57ms+wmwXIKBupsYkwuNqeWVwx8nTnu9NX3/VZ0in68=";
  nativeBuildInputs = [
    makeWrapper
  ];
  buildInputs = [
    systemd
  ];
  postInstall = ''
    mkdir -p $out/share/assets
    cp -r api static web config.json $out/share/assets
    cp -r database $out/share/
    wrapProgram $out/bin/OpenLinkHub \
      --prefix PATH : ${
        lib.makeBinPath [
          pciutils
          nvidia
        ]
      };
  '';
}
