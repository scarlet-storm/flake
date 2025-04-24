{ pkgs, lib, ... }:

# TODO: create specialisation ?
{
  boot.kernelParams = [
    "nouveau.config=NvGspRm=1"
    "nouveau.modeset=1"
    "nouveau.runpm=0"
  ];
  boot.kernelModules = [ "nouveau" ];
  nixpkgs.overlays = [
    (final: prev: {
      mesa = prev.mesa.overrideAttrs (prevAttrs: {
        src = pkgs.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "mesa";
          repo = "mesa";
          rev = "300b6f73714fd7e82491eb49db283d78495c4421";
          hash = "sha256-8jFDNsMA+MfBzPZ2PoUqSvFJ7CpIW+c11ne1P0+KrgY=";
        };
        version = "2025-04-24";
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
