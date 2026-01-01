{ pkgs, ... }: {
  systemd.services.keyboard-brightness = {
    enable = true;
    description = "Set keyboard brightness at boot";
    after = [ "basic.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.brightnessctl}/bin/brightnessctl -d "platform::kbd_backlight" set 2
      '';
    };
  };
}
