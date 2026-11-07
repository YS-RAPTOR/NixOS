{ lib, ... }: {
  den.schema.host.options.hdrOutputs = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options.backlight = lib.mkOption {
          type = lib.types.str;
          description = "Nits-based backlight whose level sets SDR white while the output is in HDR.";
        };
      }
    );
    default = { };
    description = "Outputs Hyprland keeps in HDR with a 10-bit framebuffer, keyed by output name.";
  };
}
