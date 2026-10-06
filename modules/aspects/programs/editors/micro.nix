{ ... }:
{
  flake.modules.nixos.micro = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.micro ];
  };
}
