{ settings, config, ... }:
let
  tmux = "${settings.user.extraDir}/scripts/tmux.sh";
  weather = "${settings.user.extraDir}/scripts/weather.sh";
  bluetooth = "${settings.user.extraDir}/scripts/wofi-bluetooth.sh";
  colorpicker = "${settings.user.extraDir}/scripts/colorpicker.sh";
  colors = config.lib.stylix.colors;
in {

  programs.waybar = {
    systemd.enable = true;
    enable = true;

    settings = [{
      layer = "top";
      position = "top";
      modules-left = [ "custom/logo" "clock" "custom/weather" ];
      modules-center = [ "hyprland/workspaces" ];
      modules-right = [
        "tray"
        "custom/clipboard"
        "backlight"
        "custom/colorpicker"
        "bluetooth"
        "pulseaudio"
        "network"
        "battery"
      ];
      reload_style_on_change = true;

      "custom/logo" = {
        format = "{}";
        return-type = "json";
        exec = tmux;
      };

      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "";
          "2" = "";
          "3" = "";
          "4" = "";
          "5" = "";
          "6" = "";
          "active" = "";
          "default" = "";
        };
        persistent-workspaces = { "*" = 7; };
      };

      "custom/weather" = {
        format = "{}";
        return-type = "json";
        exec = weather;
        interval = 10;
        on-click = "zen https://wttr.in";
      };

      "custom/clipboard" = {
        format = "";
        on-click = "cliphist list | wofi -dmenu | cliphist decode | wl-copy";
        interval = 86400;
      };

      "clock" = {
        tooltip = false;
        interval = 1;
        format = "{:%a %d %b %Y 󰥔 %H:%M}";
      };

      "bluetooth" = {
        format-on = "";
        format-off = "";
        format-disabled = "󰂲";
        format-connected = "󰂴";
        format-connected-battery = "{device_battery_percentage}% 󰂴";
        tooltip-format = ''
          {controller_alias}	{controller_address}

          {num_connections} connected'';
        tooltip-format-connected = ''
          {controller_alias}	{controller_address}

          {num_connections} connected

          {device_enumerate}'';
        tooltip-format-enumerate-connected = "{device_alias}	{device_address}";
        tooltip-format-enumerate-connected-battery =
          "{device_alias}	{device_address}	{device_battery_percentage}%";
        on-click = bluetooth;
      };

      "network" = {
        format-wifi = "";
        format-ethernet = "";
        format-disconnected = "";
        tooltip-format = "{ipaddr}";
        tooltip-format-wifi = "{essid} ({signalStrength}%)  | {ipaddr}";
        tooltip-format-ethernet = "{ifname} 🖧 | {ipaddr}";
        on-click = "networkmanager_dmenu";
      };

      "battery" = {
        interval = 1;
        states = {
          good = 95;
          warning = 30;
          critical = 20;
        };
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% 󰂄";
        format-plugged = "{capacity}% 󰂄 ";
        format-icons = [ "󰁻" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹" ];
      };
      "backlight" = {
        device = "intel_backlight";
        tooltip = false;
        format = "<span font='12'>{icon}</span>";
        format-icons =
          [ "" "" "" "" "" "" "" "" "" "" "" "" "" "" ];
        on-scroll-down =
          "brightnessctl -e -d intel_backlight set 5%- && brightnessctl -e -d nvidia_0 set 5%- ";
        on-scroll-up =
          "brightnessctl -e -d intel_backlight set 5%+ && brightnessctl -e -d nvidia_0 set 5%+ ";
        smooth-scrolling-threshold = 1;
      };

      "custom/colorpicker" = {
        format = "{}";
        return-type = "json";
        interval = "once";
        exec = "${colorpicker} -j";
        on-click = colorpicker;
        signal = 1;
      };

      "pulseaudio" = {
        format = "{volume}% {icon}";
        format-bluetooth = "{volume}% 󰂰";
        format-muted = "<span font='12'></span>";
        format-icons = {
          headphones = "";
          bluetooth = "󰥰";
          handsfree = "";
          headset = "󱡬";
          phone = "";
          portable = "";
          car = "";
          default = [ "🕨" "🕩" "🕪" ];
        };
        justify = "center";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";
        tooltip-format = "{icon} {volume}%";
      };

      "tray" = {
        icon-size = 14;
        spacing = 10;
      };

    }];

    style = ''
      * {
        border: none;
        font-size: 14px;
        font-family: "${config.stylix.fonts.monospace.name}";
        min-height: 15px;
        color: #${colors.base04};
      }

      #tray menu {
        background-color: #${colors.base00};
        color: #${colors.base04};
      }

      #tray menuitem:hover {
        background-color: #${colors.base03};
      }

      window#waybar {
        background: rgba(0, 0, 0, 0);
        margin: 5px;
      }

      #custom-logo {
        padding: 0px 20px;
        border-radius: 0px 15px 15px 0px;
        margin-right: 5px;
        color: #${colors.base02};
        font-weight: 900;
      }

      #custom-logo.active {
        background: #${colors.base09};
      }

      #custom-logo.inactive {
        background: #${colors.base0B};
      }

      .modules-right {
        padding-left: 5px;
        border-radius: 15px 0 0 15px;
        margin-top: 2px;
        background: #${colors.base00};
      }

      .modules-center {
        padding: 0 15px;
        margin-top: 2px;
        border-radius: 15px 15px 15px 15px;
        background: #${colors.base00};
      }

      .modules-left {
        border-radius: 0 15px 15px 0px;
        padding-right: 5px;
        margin-top: 2px;
        background: #${colors.base00};
      }

      #battery,
      #custom-clipboard,
      #custom-colorpicker,
      #bluetooth,
      #pulseaudio,
      #network,
      #backlight,
      #custom-weather,
      #tray,
      #window,
      #workspaces,
      #clock {
        padding: 0 5px;
      }

      #pulseaudio {
        padding-top: 3px;
      }

      #pulseaudio.muted {
        padding-top: 3px;
        color: #${colors.base08};
      }

      #clock {
        color: #${colors.base0C};
      }

      #battery.charging {
        color: #${colors.base04};
        background-color: #${colors.base0B};
      }

      #battery.warning:not(.charging) {
        background-color: #${colors.base09};
        color: black;
      }

      #battery.critical:not(.charging) {
        background-color: #${colors.base08};
        color: #${colors.base04};
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      @keyframes blink {
        to {
          background-color: #${colors.base04};
          color: #${colors.base00};
        }
      }
    '';

  };

}
