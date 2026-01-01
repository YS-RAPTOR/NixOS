{
  id = "home";

  system = {
    target = "x86_64-linux";
    hostname = "raptor-laptop";
    timezone = "Australia/Melbourne";
    locale = "en_AU.UTF-8";
    keyboardLayout = "au";
    unstable = true;
  };

  user = rec {
    username = "raptor";
    github-username = "YS-RAPTOR";
    name = "Yashan";
    email = "yashan.sumanaratne@gmail.com";

    homeDir = "/home/${username}";
    nixDir = "${homeDir}/NixOS";
    extraDir = "${nixDir}/extras";
  };

  packages = import ./packages.nix;

  hardware = {
    configFile = ./hardware-configuration.nix;
    gpu = {
      type = "nvidia";
      nvidia = {
        prime = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    monitors = [ "eDP-1,3200x2000@120.00Hz,auto,1.6" ];
    backlights = [
      "intel_backlight"
      "nvidia_0"
    ];
    keyboard = {
      backlight = {
        device = "platform::kbd_backlight";
        maxValue = "2";
      };
    };
  };
}
