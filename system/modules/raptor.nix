{ pkgs, settings, ... }:
let
  myScript = ''
    #!${pkgs.bash}/bin/sh

    NIX_DIR=${settings.user.nixDir};


    refresh() {
      pgrep Hyprland &> /dev/null && echo "Reloading hyprland" && hyprctl reload &> /dev/null;
      pgrep hyprpaper &> /dev/null && echo "Reapplying background via hyprpaper" && pkill hyprpaper && echo "Running hyprpaper" && hyprpaper &> /dev/null & disown;
    }

    sync() {
      sudo nixos-rebuild switch --impure --flake "$NIX_DIR";
    }

    update() {
      pushd "$NIX_DIR" &> /dev/null;
      sudo nix flake update;
      popd &> /dev/null;
    }

    if [ "$1" = "sync" ]; then
      if [ "$#" -gt 1 ]; then
          echo "Warning: The 'sync' command has no subcommands (no $2 subcommand)";
      fi
      sync;
      refresh;
      exit 0;
    elif [ "$1" = "refresh" ]; then
      if [ "$#" -gt 1 ]; then
          echo "Warning: The 'refresh' command has no subcommands (no $2 subcommand)";
      fi
      refresh;
      exit 0;
    elif [ "$1" = "update" ]; then
      if [ "$#" -gt 1 ]; then
          echo "Warning: The 'update' command has no subcommands (no $2 subcommand)";
      fi
      update;
      exit 0;
    elif [ "$1" = "upgrade" ]; then
      if [ "$#" -gt 1 ]; then
          echo "Warning: The 'upgrade' command has no subcommands (no $2 subcommand)";
      fi
      update;
      sync;
      exit 0;
    elif [ "$1" = "pull" ]; then
      if [ "$#" -gt 1 ]; then
          echo "Warning: The 'pull' command has no subcommands (no $2 subcommand)";
      fi
      pushd "$NIX_DIR" &>/dev/null
      git stash
      git pull
      git stash apply
      popd &>/dev/null
      exit 0;
    elif [ "$1" = "gc" ]; then
      if [ "$#" -gt 2 ]; then
          echo "Warning: The 'gc' command only accepts one argument (collect_older_than)";
      fi
      if [ "$2" = "full" ]; then
          sudo nix-collect-garbage --delete-old;
          nix-collect-garbage --delete-old;
      elif [ "$2" ]; then
          sudo nix-collect-garbage --delete-older-than $2;
          nix-collect-garbage --delete-older-than $2;
      else
          sudo nix-collect-garbage --delete-older-than 30d;
          nix-collect-garbage --delete-older-than 30d;
      fi
      exit 0;
    fi
    echo "Usage: $0 [sync | refresh | update | upgrade | pull | gc [full|<duration>]]"
    exit 1
  '';
in { environment.systemPackages = [ (pkgs.writeScriptBin "raptor" myScript) ]; }
