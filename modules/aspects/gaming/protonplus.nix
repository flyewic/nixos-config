{ ... }:
{
  flake.modules.nixos.protonplus = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.protonplus ];
  };
}
