{
  den.aspects.services.networking.nftables.nixos.networking = {
    nftables = {
      enable = true;
      # PIA, Tailscale, and Docker manage their own tables at runtime.
      flushRuleset = false;
    };
    firewall.enable = true;
  };
}
