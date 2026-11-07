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
        name: command:
        pkgs.writeShellScriptBin name ''
          exec ${lib.getExe pkgs.direnv} exec "$PWD" ${lib.escapeShellArgs command} "$@"
        '';
      codex = withDirenv "t3-codex-direnv" [ (lib.getExe pkgs.codex) ];
      claude = withDirenv "t3-claude-direnv" [
        (lib.getExe' pkgs.coreutils "env")
        "-u"
        "ANTHROPIC_API_KEY"
        (lib.getExe self'.packages.claude-code)
      ];
      neovim = pkgs.writeShellApplication {
        name = "t3-neovim";
        text = ''
          if [[ $1 =~ ^t3-neovim://vscode-remote/ssh-remote\+([^/]+)(/.*)$ ]]; then
            printf -v host '%b' "''${BASH_REMATCH[1]//%/\\x}"
            printf -v path '%b' "''${BASH_REMATCH[2]//%/\\x}"
            dir=$path
            [[ $path == *:1:1 ]] && path=''${path%:1:1} dir=''${path%/*}
            exec ${lib.getExe config.programs.ghostty.package} +new-window \
              -e ssh -t -- "$host" "cd ''${dir@Q} && exec nvim -- ''${path@Q}"
          fi

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
      xdg.desktopEntries.t3-neovim = {
        name = "Neovim (T3 remote)";
        exec = "${lib.getExe neovim} %u";
        noDisplay = true;
        mimeType = [ "x-scheme-handler/t3-neovim" ];
      };
      programs.t3code = {
        enable = true;
        package = self'.packages.t3-code;
        # Merge only our settings; keep T3's other user/provider settings mutable.
        mutableUserSettings = true;
        userSettings = {
          worktreesDirectory = "${config.home.homeDirectory}/Dev/.worktrees";
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
