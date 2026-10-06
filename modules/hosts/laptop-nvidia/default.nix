{ inputs, config, ... }:
let
  user = config.username;
  # Swap this one line to change compositors: hyprland | niri | river.
  # Both classes read it, so the NixOS and home-manager imports stay in sync.
  compositor = "hyprland";
in
{
  # `laptop` is the preset; this is the hybrid machine. Its disk and PRIME bus
  # IDs stay here so importing the preset alone never touches this hardware.
  flake.modules.nixos."laptop-nvidia-host" = {
    imports = [
      ./_disk.nix
      ./_hardware.nix
      inputs.self.modules.nixos.laptop
      inputs.self.modules.nixos."nvidia-prime"
      inputs.self.modules.nixos.${compositor}
    ];

    networking.hostName = "TODO_LAPTOP_NVIDIA_HOSTNAME";

    # lspci on this machine, then convert hex to decimal.
    # "0000:01:00.0" is "PCI:1@0:0:0". Set nvidiaBusId and one integrated id.
    hardware.nvidia.prime.nvidiaBusId = ""; # TODO
    hardware.nvidia.prime.intelBusId = ""; # TODO
    hardware.nvidia.prime.amdgpuBusId = ""; # TODO

    deployment = {
      targetHost = "TODO_LAPTOP_NVIDIA_HOST"; # tailscale name or IP
      targetUser = "root";
      tags = [
        "laptop"
        "laptop-nvidia"
      ];
    };

    home-manager.users.${user}.imports = [
      inputs.self.modules.homeManager.laptop
      inputs.self.modules.homeManager.${compositor}
    ];
  };
}
