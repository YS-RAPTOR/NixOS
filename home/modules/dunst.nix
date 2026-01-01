{ lib, config, ... }:
{
  services.dunst = {
    enable = true;
    settings = {
      urgency_normal = {
        frame_color = lib.mkForce "#${config.lib.stylix.colors.base0B}";
      };
    };
  };

}
