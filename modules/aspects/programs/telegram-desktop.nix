{ ... }:
{
  flake.modules.nixos.telegram-desktop = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.telegram-desktop ];
  };
}
