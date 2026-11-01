{
  den.aspects.development.toolchains.jai.homeManager = { config, pkgs, ... }: {
    home.packages = [
      (pkgs.buildFHSEnv {
        name = "jai";
        runScript = "${config.home.homeDirectory}/.local/share/jai/bin/jai-linux";
        targetPkgs = p: [
          p.zlib
          p.stdenv.cc.cc.lib
        ];
      })
    ];
  };
}
