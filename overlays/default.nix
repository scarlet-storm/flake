{ lib }:
{
  wrappers =
    final: prev:
    (lib.filesystem.packagesFromDirectoryRecursive {
      callPackage = final.callPackage;
      directory = ./wrappers;
    });

}
