{ inputs, ... }:
let
  # TODO_USER must match modules/aspects/users.nix.
  user = "TODO_USER";
in
{
  # Merges with modules/presets/vm.nix, exactly like the laptop host does.
  flake.modules.nixos.vm =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      # The nixpkgs qemu expects NixOS's /run/opengl-driver for its GBM/EGL
      # drivers. Built from a non-NixOS host that path is absent, so virgl
      # fails and aquamarine (Hyprland) gets no renderer. Point qemu at the Nix
      # Mesa instead. Harmless on a real NixOS host.
      qemuGl = pkgs.runCommand "qemu-gl" { } ''
        mkdir -p $out/bin
        for f in ${pkgs.qemu}/bin/*; do
          ln -s "$f" "$out/bin/$(basename "$f")"
        done
        rm -f $out/bin/qemu-system-x86_64
        cp ${qemuGlWrapper} $out/bin/qemu-system-x86_64
      '';
      qemuGlWrapper = pkgs.writeShellScript "qemu-system-x86_64" ''
        export GBM_BACKENDS_PATH=${pkgs.mesa}/lib/gbm
        export LIBGL_DRIVERS_PATH=${pkgs.mesa}/lib/dri
        export LD_LIBRARY_PATH=${pkgs.mesa}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
        exec ${pkgs.qemu}/bin/qemu-system-x86_64 "$@"
      '';
    in
    {
      imports = [
        ./_hardware.nix
        inputs.home-manager.nixosModules.home-manager
        inputs.self.modules.nixos.hyprland # TODO: hyprland | niri | river
      ];

      networking.hostName = "nixos-vm";
      system.stateVersion = "26.05"; # release at first install; do not bump

      # VM only: a real host picks a compositor and a display manager later.
      # ly is a text greeter, so autologin goes straight into Hyprland without
      # pulling a second compositor for the greeter.
      services.displayManager.ly = {
        enable = true;
        x11Support = false;
      };
      services.displayManager.defaultSession = "hyprland";
      services.displayManager.autoLogin = {
        enable = true;
        user = user;
      };
      # ly's stacks include login, where services.oo7 adds pam_oo7. Autologin
      # has no password, so the keyring stays locked until an app prompts.

      # Login password comes from secrets.yaml. Root has no sops hash, so it
      # keeps the known VM password. Wheel sudo stays passwordless.
      sops.secrets.user-password.neededForUsers = true;
      users.users.${user}.hashedPasswordFile = config.sops.secrets.user-password.path;
      users.users.root.initialPassword = "nixos";
      security.sudo.wheelNeedsPassword = lib.mkForce false;

      # QEMU/KVM. `virtualisation.*` QEMU options only exist in the vmVariant
      # submodule in this nixpkgs, so configure them there. virtio-vga-gl gives
      # the guest a virgl renderer; without it Hyprland cannot create a
      # renderer on virtio-gpu and cannot set the monitor mode.
      virtualisation.vmVariant.virtualisation = {
        memorySize = 4096;
        cores = 4;
        diskSize = 8192;
        graphics = true;
        qemu.package = qemuGl;
        qemu.options = [
          "-vga"
          "none"
          "-device"
          "virtio-vga-gl"
          "-display"
          "gtk,gl=on"
        ];
        # Host age identity, mounted before activation. The file is
        # /home/flye/age/vm/key.txt and is not part of this repo. virtiofsd
        # runs as the user who launched qemu, so that file has to be readable
        # by that user. Mode 644 is enough; /home/flye is mode 700.
        sharedDirectories.sops-age = {
          source = "/home/flye/age/vm";
          target = "/var/lib/sops-nix";
        };
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${user} = {
          imports = [
            inputs.self.modules.homeManager.vm
            inputs.self.modules.homeManager.hyprland # TODO: same compositor as above
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
    };
}
