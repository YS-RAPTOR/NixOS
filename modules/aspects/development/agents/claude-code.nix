{
  den.aspects.development.agents.claude-code.homeManager = { lib, self', ... }: {
    programs.claude-code = {
      enable = true;
      package = self'.packages.claude-code;
      # The Home Manager module installs a personal plugin without replacing
      # mutable Claude settings, credentials or other user MCP registrations.
      mcpServers.cua-driver = {
        command = lib.getExe self'.packages.cua-driver;
        args = [ "mcp" ];
        env = {
          CUA_DRIVER_RS_ENABLE_WAYLAND = "1";
          CUA_DRIVER_RS_TELEMETRY_ENABLED = "false";
          NO_AT_BRIDGE = "0";
        };
      };
    };
  };
}
