{
  den.aspects.development.tools.direnv.homeManager = { config, ... }: {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.log_filter = "^$";
        whitelist.prefix = [ "${config.home.homeDirectory}/Dev/" ];
      };
    };
  };
}
