---
name: temp-exe
description: Run a missing executable temporarily (May provision temporary executables without asking).
---

If the project's flake provides the executable, use that package or dev shell. Otherwise, run it from nixpkgs with `nix run` or `nix shell`, searching for the package attribute only when unsure.
