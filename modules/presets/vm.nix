{ inputs, ... }:
{
  # A disposable QEMU/KVM box for the shared seat and dev tools.
  # Everyday apps stay on the apps preset. The vm host module merges
  # into this by sharing the name.
  flake.modules.nixos.vm = {
    imports = with inputs.self.modules.nixos; [
      common
      dev
      graphical
      oo7
    ];
  };

  flake.modules.homeManager.vm = {
    imports = with inputs.self.modules.homeManager; [
      common
      dev
      graphical
    ];
  };
}
