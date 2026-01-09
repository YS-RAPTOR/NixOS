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
    wallpaper = "${extraDir}/Work Wallpaper.jpg";
  };

  packages = import ./packages.nix;

  hardware = {
    configFile = ./hardware-configuration.nix;
    gpu = { type = "intel"; };
    monitors =
      [ "eDP-1,1920x1200@60,960x0,1" "DP-1,1920x1080@74.99Hz,0x-1080,1" ];
    backlights = [ "intel_backlight" ];
    keyboard = {
      backlight = {
        device = "tpacpi::kbd_backlight";
        maxValue = "2";
      };
    };
  };
}
