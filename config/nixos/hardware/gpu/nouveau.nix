{
  pkgs,
  lib,
  ...
}:

# TODO: create specialisation ?
{
  boot.kernelParams = [
    "nouveau.config=NvGspRm=1"
    "nouveau.modeset=1"
  ];
  systemd.globalEnvironment = {
    "NOUVEAU_USE_ZINK" = "1";
  };
  boot.kernelModules = [ "nouveau" ];
  nixpkgs.overlays = [
    (final: prev: {
      mesa = prev.mesa.overrideAttrs (prevAttrs: {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "mesa";
          repo = "mesa";
          rev = "ed58b869e1ce68090d62297e06bae4afd24827be";
          hash = "sha512-O6VarKF2Z6zKoS8tPtMNJ9oFmnV1kTj4pGD+EoQLTOZc18RIqY9wPEL55XNj5cJdMhtZJoKkCyxw0LruDEHkNA==";
        };
        version = "20241221";
        patches = [ ];
        mesonFlags =
          builtins.filter (
            f:
            !builtins.any (opt: lib.hasPrefix "${opt}" f) [
              "-Ddri-search-path"
              "-Domx-libs-path"
              "-Dopencl-spirv"
              "-Dclang-libdir"
              "--sysconfdir=/etc"
            ]
          ) prevAttrs.mesonFlags
          ++ [
          ];
        preConfigure =
          prevAttrs.preConfigure
          + ''
            substituteInPlace meson.build \
            --replace-fail "llvm_libdir = dep_llvm.get_variable(cmake : 'LLVM_LIBRARY_DIR', configtool: 'libdir')" \
            "llvm_libdir = '${lib.getLib prev.llvmPackages.clang-unwrapped}/lib'"
          '';
      });
    })
  ];
}
