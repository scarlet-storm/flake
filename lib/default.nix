{ lib, ... }:
# from lib.filesystem.packagesFromDirectoryRecursive
let
  processDir =
    { callModule, directory }@args:
    lib.concatMapAttrs (
      name: type:
      let
        path = "${directory}/${name}";
      in
      if type == "directory" then
        { "${name}" = modulesFromDirectory (args // { directory = path; }); }
      else if type == "regular" && lib.hasSuffix ".nix" name then
        { "${lib.removeSuffix ".nix" name}" = callModule path; }
      else
        { }
    ) (builtins.readDir directory);
  modulesFromDirectory =
    { callModule, directory }@args:
    let
      defaultPath = "${directory}/default.nix";
    in
    if builtins.pathExists defaultPath then callModule defaultPath else processDir args;
in
{
  inherit modulesFromDirectory;
}
