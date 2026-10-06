{ ... }:
{
  flake.modules.nixos.goverlay = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.goverlay ];
  };
}
