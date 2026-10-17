{ lib, ... }:
let
  launchTarget = lib.types.submodule {
    options = {
      command = lib.mkOption {
        type = lib.types.str;
        description = "Command to launch the application.";
      };
      focusClass = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional Hyprland window-class regex to focus instead of launching.";
      };
    };
  };
in
{
  den.default.homeManager.options.desktop.commands =
    lib.genAttrs [ "browser" "privateBrowser" "fileManager" "launcher" "orchestrator" "terminal" ]
      (
        name:
        lib.mkOption {
          type = lib.types.nullOr launchTarget;
          default = null;
          description = "Default ${name} launch target.";
        }
      );
}
