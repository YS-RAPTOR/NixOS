{ ... }: {
  den.aspects.development.mcp.clients.homeManager =
    {
      config,
      lib,
      pkgs,
      self',
      ...
    }:
    {
      programs.claude-code.mcpServers.executor = {
        command = lib.getExe self'.packages.executor;
        args = [ "mcp" ];
      };

      # Codex's editor preserves all other mutable settings and MCP registrations.
      home.activation.codexExecutorMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CODEX_HOME=${lib.escapeShellArg "${config.home.homeDirectory}/.codex"} \
          run ${lib.getExe pkgs.codex} mcp add executor -- ${lib.getExe self'.packages.executor} mcp
      '';
    };
}
