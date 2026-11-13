{ ... }: {
  den.aspects.development.mcp.executor.homeManager = { lib, self', ... }: {
    home.packages = [ self'.packages.executor ];

    systemd.user.services.executor = {
      Unit = {
        Description = "Executor MCP integration gateway";
        After = [
          "graphical-session.target"
          "gnome-keyring.service"
        ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe self'.packages.executor} serve";
        Restart = "on-failure";
        RestartSec = 5;
        UMask = "0077";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
