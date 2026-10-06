{ ... }:
{
  flake.modules.nixos.neovim = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.neovim ];
  };
}
