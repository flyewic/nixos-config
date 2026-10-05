{ inputs, ... }:
let
  # TODO_USER must match modules/aspects/users.nix.
  user = "TODO_USER";
in
{
  flake.modules.nixos.laptop = {
    imports = [
      ./_disk.nix
      ./_hardware.nix
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      inputs.colmena.nixosModules.deploymentOptions
      # The laptop preset is also flake.modules.nixos.laptop, so it merges
      # into this module. Importing it here would loop.
      inputs.self.modules.nixos.hyprland # TODO: hyprland | niri | river
    ];

    networking.hostName = "TODO_LAPTOP_HOSTNAME";
    system.stateVersion = "26.05"; # release at first install; do not bump

    deployment = {
      targetHost = "TODO_LAPTOP_HOST"; # tailscale name or IP
      targetUser = "root";
      tags = [ "laptop" ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user}.imports = [
        inputs.self.modules.homeManager.laptop
        inputs.self.modules.homeManager.hyprland # TODO: same compositor as above
      ];
    };
  };
}
