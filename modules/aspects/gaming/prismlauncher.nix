{ ... }:
{
  flake.modules.nixos.prismlauncher = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.prismlauncher ];
  };
}
