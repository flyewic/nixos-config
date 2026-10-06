{ inputs, config, ... }:
let
  user = config.username;
  # Swap this one line to change compositors: hyprland | niri | river.
  # Both classes read it, so the NixOS and home-manager imports stay in sync.
  compositor = "hyprland";
in
{
  flake.modules.nixos."desktop-host" = {
    imports = [
      ./_disk.nix
      ./_hardware.nix
      inputs.self.modules.nixos.workstation
      inputs.self.modules.nixos.${compositor}
    ];

    networking.hostName = "bropor";
    time.timeZone = "Europe/Stockholm";

    deployment = {
      targetHost = "TODO_DESKTOP_HOST"; # tailscale name or IP
      targetUser = "root";
      tags = [
        "workstation"
        "desktop"
      ];
    };

    home-manager.users.${user}.imports = [
      inputs.self.modules.homeManager.workstation
      inputs.self.modules.homeManager.${compositor}
    ];
  };
}
