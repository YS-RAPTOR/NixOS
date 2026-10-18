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
      # T3's "Open in Neovim" runs `t3-neovim --goto PATH:LINE[:COLUMN]` or `t3-neovim PATH`.
      # `+new-window` has the running Ghostty open the window, outside T3's sandbox.
      neovim = pkgs.writeShellApplication {
        name = "t3-neovim";
        text = ''
          target=$1
          position=()
          if [[ $1 == --goto && $2 =~ :([0-9]+)(:([0-9]+))?$ ]]; then
            target=''${2%"''${BASH_REMATCH[0]}"}
            position=("+call cursor(''${BASH_REMATCH[1]},''${BASH_REMATCH[3]:-1})")
          fi
          dir=$target
          [[ -d $dir ]] || dir=''${target%/*}
          exec ${lib.getExe config.programs.ghostty.package} +new-window --working-directory="$dir" \
            -e ${lib.getExe config.programs.neovim.finalPackage} "''${position[@]}" -- "$target"
        '';
      };
    in
    {
      desktop.commands.orchestrator = {
        command = lib.getExe config.programs.t3code.package;
        focusClass = "^com\\.t3tools\\.T3Code$";
      };
      home.packages = [
        codex
        claude
        neovim
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
