{ inputs, ... }:
let
  # TODO_USER must match modules/aspects/users.nix.
  user = "TODO_USER";
in
{
  flake.modules.nixos.desktop = {
    imports = [
      ./_disk.nix
      ./_hardware.nix
      inputs.disko.nixosModules.disko
      inputs.home-manager.nixosModules.home-manager
      inputs.colmena.nixosModules.deploymentOptions
      inputs.self.modules.nixos.workstation
      inputs.self.modules.nixos.hyprland # TODO: hyprland | niri | river
    ];

    networking.hostName = "TODO_DESKTOP_HOSTNAME";
    system.stateVersion = "26.05"; # release at first install; do not bump

    deployment = {
      targetHost = "TODO_DESKTOP_HOST"; # tailscale name or IP
      targetUser = "root";
      tags = [
        "workstation"
        "desktop"
      ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user}.imports = [
        inputs.self.modules.homeManager.workstation
        inputs.self.modules.homeManager.hyprland # TODO: same compositor as above
      ];
    };
  };
}
