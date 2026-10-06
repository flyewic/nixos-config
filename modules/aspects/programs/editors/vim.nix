{ ... }:
{
  flake.modules.nixos.vim = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.vim ];
  };
}
