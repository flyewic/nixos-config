{ ... }:
{
  flake.modules.nixos.bitwarden = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.bitwarden-desktop ];
  };
}
