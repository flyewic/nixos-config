{ inputs, config, ... }:
let
  user = config.username;
  # Swap this one line to change compositors: hyprland | niri | river.
  # Both classes read it, so the NixOS and home-manager imports stay in sync.
  compositor = "hyprland";
in
{
  # Host modules are namespaced with `-host` so they can never collide with a
  # preset of the same name. The `laptop` preset is imported here; the disk
  # stays on this module, so `laptop-nvidia` can import the preset alone.
  flake.modules.nixos."laptop-host" = {
    imports = [
      ./_disk.nix
      ./_hardware.nix
      inputs.self.modules.nixos.laptop
      inputs.self.modules.nixos.${compositor}
    ];

    networking.hostName = "TODO_LAPTOP_HOSTNAME";

    deployment = {
      targetHost = "TODO_LAPTOP_HOST"; # tailscale name or IP
      targetUser = "root";
      tags = [ "laptop" ];
    };

    home-manager.users.${user}.imports = [
      inputs.self.modules.homeManager.laptop
      inputs.self.modules.homeManager.${compositor}
    ];
  };
}
