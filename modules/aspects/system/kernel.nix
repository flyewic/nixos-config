{ ... }:
{
  flake.modules.nixos.kernel = { pkgs, ... }: {
    # The default kernel on this nixos-unstable pin is the 6.18 LTS.
    # linuxPackages_latest is the current mainline in the same pin.
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
