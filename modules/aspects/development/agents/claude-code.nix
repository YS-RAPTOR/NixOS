{ ... }: {
  den.aspects.development.agents.claude-code.homeManager = { lib, self', ... }: {
    home.file = {
      ".claude/CLAUDE.md".source = ./_files/AGENTS.md;
    }
    // import ./_lib/skill-links.nix {
      inherit lib;
      destination = ".claude/skills";
    };

    programs.claude-code = {
      enable = true;
      package = self'.packages.claude-code;
    };
  };
}
