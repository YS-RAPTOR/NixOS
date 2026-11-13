{ den, inputs, ... }: {
  den.aspects.development.mcp.cua = {
    includes = [ den.aspects.development.computer-use.cua-driver ];

    homeManager =
      { lib, pkgs, ... }:
      let
        driver = inputs.cua.packages.${pkgs.stdenv.hostPlatform.system}.cua-driver;
        start = pkgs.writeShellApplication {
          name = "cua-mcp-http";
          runtimeInputs = [
            pkgs.coreutils
            pkgs.openssl
          ];
          text = ''
            # Persist the bearer token outside the Nix store; never print it in logs.
            token_file="$STATE_DIRECTORY/cua-token"
            umask 077
            if [[ ! -s "$token_file" ]]; then
              openssl rand -hex 32 > "$token_file"
            fi
            export CUA_DRIVER_RS_MCP_HTTP_TOKEN
            CUA_DRIVER_RS_MCP_HTTP_TOKEN="$(cat "$token_file")"
            exec ${lib.getExe driver} serve --socket "$XDG_RUNTIME_DIR/cua-mcp/driver.sock"
          '';
        };
      in
      {
        systemd.user.services.cua-mcp = {
          Unit = {
            Description = "CUA MCP HTTP server for Executor";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = lib.getExe start;
            Environment = [
              "CUA_DRIVER_RS_MCP_HTTP_PORT=4313"
              "CUA_DRIVER_RS_ENABLE_WAYLAND=1"
              "CUA_DRIVER_RS_TELEMETRY_ENABLED=false"
              "NO_AT_BRIDGE=0"
            ];
            StateDirectory = "mcp";
            StateDirectoryMode = "0700";
            RuntimeDirectory = "cua-mcp";
            RuntimeDirectoryMode = "0700";
            UMask = "0077";
            Restart = "on-failure";
            RestartSec = 5;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
  };
}
