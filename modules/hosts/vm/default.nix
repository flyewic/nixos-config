{ inputs, config, ... }:
let
  user = config.username;
  # Swap this one line to change compositors: hyprland | niri | river.
  # Both classes read it, so the NixOS and home-manager imports stay in sync.
  compositor = "hyprland";
in
{
  flake.modules.nixos."vm-host" =
    {
      config,
      lib,
      ...
    }:
    {
      imports = [
        ./_hardware.nix
        ./_qemu.nix
        inputs.self.modules.nixos.vm
        inputs.self.modules.nixos.${compositor}
      ];

      networking.hostName = "nixos-vm";

      # Login password comes from secrets.yaml. Root has no sops hash, so it
      # keeps the known VM password. Wheel sudo stays passwordless.
      sops.secrets.user-password.neededForUsers = true;
      users.users.${user}.hashedPasswordFile = config.sops.secrets.user-password.path;
      users.users.root.initialPassword = "nixos";
      security.sudo.wheelNeedsPassword = lib.mkForce false;

      # QEMU/KVM. `virtualisation.*` QEMU options only exist in the vmVariant
      # submodule in this nixpkgs, so configure them there. virtio-vga-gl gives
      # the guest a virgl renderer; without it Hyprland cannot create a
      # renderer on virtio-gpu and cannot set the monitor mode. The wrapped
      # qemu package is in ./_qemu.nix.
      virtualisation.vmVariant.virtualisation = {
        memorySize = 4096;
        cores = 4;
        diskSize = 8192;
        graphics = true;
        qemu.options = [
          "-vga"
          "none"
          "-device"
          "virtio-vga-gl"
          "-display"
          "gtk,gl=on"
        ];
        # Host age identity, mounted before activation. key.txt in `source`
        # is not part of this repo. It is mode 0600 in a 0700 directory.
        # virtiofsd runs as
        # the user who launched qemu (--sandbox=none) and guest root is not
        # remapped onto a host uid: the host:65534:0:1 translate only decides
        # how ownership is displayed in the guest. So the daemon reads as that
        # user, and mode 0600 is enough.
        sharedDirectories.sops-age = {
          source = "/home/${user}/age/vm";
          target = "/var/lib/sops-nix";
        };
      };

      home-manager.users.${user} = {
        imports = [
          inputs.self.modules.homeManager.vm
          inputs.self.modules.homeManager.${compositor}
        ];

        # Host-private Hyprland overrides, applied after the shared aspect so
        # lib.mkForce wins. The host compositor owns Super, so the VM uses Alt
        # for the shared binds. 1920x1080 is in the guest's mode list and is
        # fast under virgl; 3840x2160 with scale 2 is sharper but slower.
        wayland.windowManager.hyprland.settings = {
          mod = lib.mkForce {
            _var = "ALT";
          };
          monitor = lib.mkForce {
            output = "";
            mode = "1920x1080@60";
            position = "auto";
            scale = 1;
          };
        };
      };
    };
}
