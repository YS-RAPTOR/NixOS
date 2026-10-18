{
  den.aspects.services.containers.docker.includes = [
    ({ user, host, ... }: {
      name = "docker(${user.userName}@${host.name})";

      nixos =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        {
          virtualisation.docker = {
            enable = true;
            daemon.settings."firewall-backend" = lib.mkIf config.networking.nftables.enable "nftables";
            extraPackages = lib.optionals config.networking.nftables.enable [ pkgs.nftables ];
          };
          users.users.${user.userName}.extraGroups = [ "docker" ];
        };
    })
  ];
}
