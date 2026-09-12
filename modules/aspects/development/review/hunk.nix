{ inputs, ... }:
{
    den.aspects.development.review.hunk.homeManager =
        {
            config,
            lib,
            pkgs,
            ...
        }:
        let
            hunk = inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.default;
            # GitHub owner/repository[@ref], or an example from the pinned Hunk input.
            extensions = [
                "modem-dev/hunk-gh"
                "examples/rendered-markdown"
            ];
            installExtensions = pkgs.writeShellApplication {
                name = "hunk-install-extensions";
                runtimeInputs = [
                    hunk
                    pkgs.git
                    pkgs.openssh
                    pkgs.bun
                    pkgs.coreutils
                ];
                runtimeEnv.HUNK_EXAMPLES_SOURCE = "${inputs.hunk}/examples/extensions";
                text = builtins.readFile ./_scripts/install-extensions.sh;
            };
        in
        {
            home.packages = [ hunk ];

            # Bootstrap writable extensions once; subsequent activations preserve them.
            # Requires network on first activation. Hunk manages repository updates;
            # examples are writable copies. Removing a source does not uninstall it.
            home.activation.hunkExtensions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                run ${lib.getExe installExtensions} ${lib.escapeShellArgs ([ config.xdg.configHome ] ++ extensions)}
            '';
        };
}
