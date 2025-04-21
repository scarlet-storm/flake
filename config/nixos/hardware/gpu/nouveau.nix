{ pkgs, lib, ... }:

# TODO: create specialisation ?
{
  boot.kernelParams = [
    "nouveau.config=NvGspRm=1"
    "nouveau.modeset=1"
  ];
  boot.kernelModules = [ "nouveau" ];
  nixpkgs.overlays = [
    (final: prev: {
      mesa = prev.mesa.overrideAttrs (prevAttrs: {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "mesa";
          repo = "mesa";
          rev = "mesa-25.1.0-rc1";
          hash = "sha256-vQrTGGhIfy41uaCQ4rg+ZlCp43qI1wMK6QIrGKr4+Ts=";
        };
        version = "25.1.0-rc1";
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
          ++ [ ];
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
