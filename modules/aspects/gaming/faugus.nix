{ ... }:
{
  flake.modules.nixos.faugus = { pkgs, ... }: {
    environment.systemPackages = [ pkgs."faugus-launcher" ];
  };
}
