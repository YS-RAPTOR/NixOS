---
name: nixos
description: Inspect or change NixOS and Home Manager configuration, including persistent package installation.
---

Run configuration commands from `~/NixOS`.

- Make persistent changes through the existing Nix modules.
- Inspect related configuration and follow the repository's conventions; place new files alongside it.
- After editing, use the repository's formatter and build the affected package or configuration.
- When validating untracked files, use a `path:` flake source without changing Git staging.
- Ask before activating system or Home Manager changes.

For package installation or custom packaging, read [PACKAGES.md](./PACKAGES.md).
