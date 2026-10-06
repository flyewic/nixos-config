{ ... }:
{
  # One zstd device, half of RAM, priority 5. That priority sits above the
  # disk swapfiles, so pressure hits zram first. The swapfile stays the
  # hibernation image: a zram device is gone after power off.
  flake.modules.nixos.zram = {
    zramSwap.enable = true;
  };
}
