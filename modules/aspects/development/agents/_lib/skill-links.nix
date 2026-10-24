{ lib, destination }:
let
  skills = lib.filterAttrs (
    name: type: type == "directory" && builtins.pathExists (../_files/skills + "/${name}/SKILL.md")
  ) (builtins.readDir ../_files/skills);
in
# Link each skill directory whole. Codex skips symlinked SKILL.md files, so
# per-file links (`recursive = true`) hide every skill from it.
# Home Manager removes the link once a skill leaves _files/skills.
lib.mapAttrs' (name: _: lib.nameValuePair "${destination}/${name}" { source = ../_files/skills + "/${name}"; }) skills
