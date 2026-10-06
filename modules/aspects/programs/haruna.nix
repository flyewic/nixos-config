{ ... }:
{
  flake.modules.nixos.haruna = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.haruna ];
  };
}
