{
  id = "work";

  system = {
    target = "x86_64-linux";
    hostname = "raptor-work";
    timezone = "Australia/Melbourne";
    locale = "en_AU.UTF-8";
    keyboardLayout = "au";
    unstable = true;
  };

  user = rec {
    username = "yashan";
    github-username = "yashan-sumanaratne";
    name = "Yashan";
    email = "yashan.sumanaratne@oolio.com";

    homeDir = "/home/${username}";
    nixDir = "${homeDir}/NixOS";
    extraDir = "${nixDir}/extras";
  };

  packages = import ./packages.nix;

  hardware = {
    configFile = ./hardware-configuration.nix;
    gpu = { type = "intel"; };
    monitors = [ ",preferred,auto,1" ];
    backlights = [ "intel_backlight" ];
    keyboard = {
      backlight = {
        device = "tpacpi::kbd_backlight";
        maxValue = "2";
      };
    };
  };
}
