{ ... }:
{
  flake.modules.nixos.bitwarden = {
    services.flatpak.packages = [ "com.bitwarden.desktop" ];
  };
}
