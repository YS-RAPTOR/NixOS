{ settings, ... }: {
  imports = [
    ./bluetooth.nix
    ./boot.nix
    ./gpg.nix
    ./hyprland.nix
    ./login.nix
    ./pipewire.nix
    ./raptor.nix
    ./startup.nix
    ./stylix.nix
    ./time-locale.nix
  ] ++ {
    home = [ ./nvidia.nix ];
    work = [ ];
  }."${settings.id}";
}

