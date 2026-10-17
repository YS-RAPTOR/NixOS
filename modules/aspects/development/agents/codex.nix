{
  den.aspects.development.agents.codex.homeManager =
    {
      config,
      lib,
      pkgs,
      self',
      ...
    }:
    {
      home.packages = [ pkgs.codex ];

      # Codex owns a mutable config.toml (projects, marketplace state, etc.).
      # Its native editor updates only this MCP registration, preserving the rest.
      home.activation.codexCuaMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CODEX_HOME=${lib.escapeShellArg "${config.home.homeDirectory}/.codex"} \
          run ${lib.getExe pkgs.codex} mcp add cua-driver \
            --env CUA_DRIVER_RS_ENABLE_WAYLAND=1 \
            --env CUA_DRIVER_RS_TELEMETRY_ENABLED=false \
            --env NO_AT_BRIDGE=0 \
            -- ${lib.getExe self'.packages.cua-driver} mcp
      '';
    };
}
