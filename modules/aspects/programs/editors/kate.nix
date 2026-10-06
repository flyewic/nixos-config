{ ... }:
{
  flake.modules.nixos.kate = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.kdePackages.kate ];
  };
}
