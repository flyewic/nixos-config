{ ... }:
{
  flake.modules.nixos.spotify = {
    services.flatpak.packages = [ "com.spotify.Client" ];
  };
}
