{ ... }:
{
  flake.modules.nixos.opencode-desktop = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.opencode-desktop ];
  };
}
