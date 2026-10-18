# Packages

Prefer existing packages from the active nixpkgs input, other flake inputs or local definitions; check upstream Nix support before packaging yourself.

1. **Define.** Put custom packages in `~/NixOS/packages/`, following nearby examples.
2. **Maintain.** For updater-managed packages, keep source pins in `sources.json` and update rules in `update.json`. Extend `packages/update.sh` with another source type when needed.
3. **Integrate and validate.** Wire the package into the appropriate module, run its updater when applicable, build it and validate the affected host or user configuration.
