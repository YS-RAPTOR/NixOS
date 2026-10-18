{ inputs, ... }: {
  den.aspects.development.computer-use.cua-driver.nixos = { lib, pkgs, ... }: {
    imports = [ inputs.cua.nixosModules.cua-driver ];

    services.cua-driver = {
      enable = true;
      package = inputs.cua.packages.${pkgs.stdenv.hostPlatform.system}.cua-driver;
    };

    environment = {
      variables = {
        CUA_DRIVER_RS_ENABLE_WAYLAND = "1";
        CUA_DRIVER_RS_TELEMETRY_ENABLED = "false";
        NO_AT_BRIDGE = lib.mkForce "0";
      };
    };
  };
}
