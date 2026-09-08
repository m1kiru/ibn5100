{ lib, ... }:
let
  isNixFile = name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix";
in
{
  imports = lib.mapAttrsToList (name: _: ./. + "/${name}") (lib.filterAttrs isNixFile (builtins.readDir ./.));
}
