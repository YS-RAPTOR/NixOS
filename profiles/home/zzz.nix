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
    # font, fontPkg
  };

  packages = import ./packages.nix;
}
