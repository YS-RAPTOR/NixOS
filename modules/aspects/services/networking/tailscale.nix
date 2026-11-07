{ den, ... }: {
  den.aspects.services.networking.tailscale = {
    includes = [ den.aspects.services.networking.nftables ];

    nixos = { config, lib, ... }: {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        extraSetFlags = [ "--ssh" ];
      };

      programs.ssh.extraConfig = ''
        Host *.ts.net
          ProxyCommand ${lib.getExe' config.services.tailscale.package "tailscale"} nc %h %p
      '';

      networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
      systemd.services.tailscaled.environment.TS_DEBUG_FIREWALL_MODE = "nftables";
    };
  };
}
