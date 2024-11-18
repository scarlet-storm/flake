{
  lib,
  fetchFromGitHub,
  buildGoModule,
  systemd,
  pciutils,
  withNvidia ? false,
  nvidiaPackage ? null,
  makeWrapper,
  writeText,
}:

buildGoModule rec {
  pname = "OpenLinkHub";
  version = "2024-11-10";
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "jurkovic-nikola";
    repo = "OpenLinkHub";
    rev = "6b352df05e17dd4d4a49e5be3045e4a0459266e2";
    hash = "sha512-964wy9+MJUxFa1FCwoOnGR0kta4m83EHRzLsiCqKwQJv0g1vG3HvaYk4/V3mGLJleHAHehYoNfRaCL7bEDf8bQ==";

  };
  patches = [
    (writeText "OpenLinkHub-link-titan.patch" ''
      diff --git a/src/devices/lsh/lsh.go b/src/devices/lsh/lsh.go
      index d4062cc..f07392a 100644
      --- a/src/devices/lsh/lsh.go
      +++ b/src/devices/lsh/lsh.go
      @@ -231,6 +231,7 @@ var (
       		{DeviceId: 11, Model: 5, Name: "iCUE LINK TITAN H150i", LedChannels: 20, ContainsPump: true, Desc: "AIO", AIO: true, HasSpeed: true},
       		{DeviceId: 11, Model: 1, Name: "iCUE LINK TITAN H115i", LedChannels: 20, ContainsPump: true, Desc: "AIO", AIO: true, HasSpeed: true},
       		{DeviceId: 11, Model: 3, Name: "iCUE LINK TITAN H170i", LedChannels: 20, ContainsPump: true, Desc: "AIO", AIO: true, HasSpeed: true},
      +		{DeviceId: 17, Model: 5, Name: "iCUE LINK TITAN 360RX", LedChannels: 20, ContainsPump: true, Desc: "AIO", AIO: true, HasSpeed: true},
       		{DeviceId: 5, Model: 0, Name: "iCUE LINK ADAPTER", LedChannels: 0, ContainsPump: false, Desc: "Adapter", LinkAdapter: true},
       	}
       )
    '')
  ];
  vendorHash = "sha256-57ms+wmwXIKBupsYkwuNqeWVwx8nTnu9NX3/VZ0in68=";
  nativeBuildInputs = [
    makeWrapper
  ];
  buildInputs = [
    systemd
  ];
  postInstall = ''
    mkdir -p $out/share/assets
    cp -r api static web $out/share/assets
    cp -r database config.json $out/share/
    wrapProgram $out/bin/OpenLinkHub \
      --prefix PATH : ${
        lib.makeBinPath (
          [
            pciutils
          ]
          ++ lib.optional withNvidia nvidiaPackage
        )
      };
  '';
}
