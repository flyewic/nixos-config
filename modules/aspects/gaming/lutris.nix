{ ... }:
{
  flake.modules.nixos.lutris = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.lutris ];
  };
}
