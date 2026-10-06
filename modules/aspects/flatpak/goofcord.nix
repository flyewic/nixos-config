{ ... }:
{
  flake.modules.nixos.goofcord = {
    services.flatpak.packages = [ "io.github.milkshiift.GoofCord" ];
  };
}
