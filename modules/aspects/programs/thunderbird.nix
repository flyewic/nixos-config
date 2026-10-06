{ ... }:
{
  flake.modules.nixos.thunderbird = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.thunderbird ];
  };
}
