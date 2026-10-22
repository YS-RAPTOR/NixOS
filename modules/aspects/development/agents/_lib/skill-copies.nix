{
  lib,
  pkgs,
  destination,
}:
let
  skills = lib.filterAttrs (
    name: type: type == "directory" && builtins.pathExists (../_files/skills + "/${name}/SKILL.md")
  ) (builtins.readDir ../_files/skills);
in
# Remove Home Manager's previous links before replacing them with regular files.
lib.hm.dag.entryAfter [ "linkGeneration" ] (
  lib.concatMapStringsSep "\n" (
    name:
    let
      source = ../_files/skills + "/${name}";
      target = lib.escapeShellArg "${destination}/${name}";
    in
    ''
      run ${pkgs.coreutils}/bin/mkdir -p -- ${target}
      run ${pkgs.coreutils}/bin/cp --recursive --dereference --remove-destination -- ${source}/. ${target}/
      run ${pkgs.coreutils}/bin/chmod -R u+w -- ${target}
    ''
  ) (builtins.attrNames skills)
)
