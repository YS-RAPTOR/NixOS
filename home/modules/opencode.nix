{ ... }:
{
  programs.opencode = {
    enable = true;
    settings = {
      theme = "stylix";
      autoupdate = true;
      disabled_providers = [
        "amazon-bedrock"
        "github-models"
      ];
      model = "github-copilot/claude-opus-4.5";
      small_model = "github-copilot/gpt-5-mini";
      permission = {
        bash = {
          "git status" = "allow";
          "git diff" = "allow";
          "git worktree list" = "allow";
          "git log" = "allow";
          "git show" = "allow";
          "git shortlog" = "allow";
          "git reflog" = "allow";
          "git blame" = "allow";
          "git describe" = "allow";
          "git ls-files" = "allow";
          "git grep" = "allow";
          "git bisect log" = "allow";
          "git " = "ask";
          "" = "allow";
        };
      };
      keybinds = {
        leader = "ctrl+f";
        messages_half_page_down = "ctrl+d";
        messages_half_page_up = "ctrl+u";
        messages_last = "alt+g";
      };
      instructions = [
        "CONTRIBUTING.md"
        "docs/guidelines.md"
        ".cursor/rules/.md"
        ".github/**/.md"
      ];
    };
  };
}
