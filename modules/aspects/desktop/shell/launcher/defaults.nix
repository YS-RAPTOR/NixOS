{ den, ... }: {
  den.batteries.desktop.shell.launcher.defaults.wofi = {
    includes = [ den.aspects.desktop.shell.launcher.wofi ];
    homeManager.desktop.commands.launcher.command = "wofi --show drun";
  };
}
