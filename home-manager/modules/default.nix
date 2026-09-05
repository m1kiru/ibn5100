{ lib, ... }:
let
  entries = builtins.readDir ./.;

  isNixFile = name: type:
    type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix";

  isModuleDir = name: type:
    type == "directory" && builtins.pathExists (./. + "/${name}/default.nix");
in
{
  imports =
    (lib.mapAttrsToList (name: _: ./. + "/${name}") (lib.filterAttrs isNixFile entries))
    ++ (lib.mapAttrsToList (name: _: ./. + "/${name}") (lib.filterAttrs isModuleDir entries));
}
