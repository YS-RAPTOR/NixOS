{ ... }: {
  den.aspects.development.agents.codex.homeManager = { lib, pkgs, ... }: {
    home.packages = [ pkgs.codex ];

    home.file = {
      ".codex/AGENTS.md".source = ./_files/AGENTS.md;
    }
    // import ./_lib/skill-links.nix {
      inherit lib;
      destination = ".agents/skills";
    };
  };
}
