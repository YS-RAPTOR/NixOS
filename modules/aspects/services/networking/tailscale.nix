{ den, ... }: {
  den.aspects.services.networking.tailscale = {
    includes = [ den.aspects.services.networking.nftables ];

    nixos = { config, ... }: {
      services.tailscale = {
        enable = true;
        openFirewall = true;
      };

      networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
      systemd.services.tailscaled.environment.TS_DEBUG_FIREWALL_MODE = "nftables";
    };
  };
}
