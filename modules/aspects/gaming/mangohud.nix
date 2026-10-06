{ ... }:
{
  flake.modules.nixos.mangohud = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.mangohud ];
    programs.steam.extraPackages = [ pkgs.mangohud ];
  };
}
