{ lib, destination }:
let
  skills = lib.filterAttrs (
    name: type: type == "directory" && builtins.pathExists (../_files/skills + "/${name}/SKILL.md")
  ) (builtins.readDir ../_files/skills);
in
lib.mapAttrs' (
  name: _:
  lib.nameValuePair "${destination}/${name}" {
    source = ../_files/skills + "/${name}";
    recursive = true;
  }
) skills
