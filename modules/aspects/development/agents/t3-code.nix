{
  den.aspects.development.agents.t3-code.homeManager =
    {
      config,
      lib,
      pkgs,
      self',
      ...
    }:
    let
      withDirenv =
        name: executable:
        pkgs.writeShellScriptBin name ''
          exec ${lib.getExe pkgs.direnv} exec "$PWD" ${lib.escapeShellArg executable} "$@"
        '';
      codex = withDirenv "t3-codex-direnv" (lib.getExe pkgs.codex);
      claude = withDirenv "t3-claude-direnv" (lib.getExe self'.packages.claude-code);
    in
    {
      desktop.commands.orchestrator = {
        command = lib.getExe config.programs.t3code.package;
        focusClass = "^t3code$";
      };
      home.packages = [
        codex
        claude
      ];
      home.sessionVariables.T3CODE_TELEMETRY_ENABLED = "false";
      programs.t3code = {
        enable = true;
        package = self'.packages.t3-code;
        # Merge only our settings; keep T3's other user/provider settings mutable.
        mutableUserSettings = true;
        userSettings = {
          worktreesDirectory = "${config.home.homeDirectory}/Dev/worktrees";
          providerInstances = {
            codex = {
              driver = "codex";
              config.binaryPath = lib.getExe codex;
            };
            claudeAgent = {
              driver = "claudeAgent";
              config.binaryPath = lib.getExe claude;
            };
          };
        };
      };
    };
}
