{ ... }:
{
  flake.modules.nixos.zen = {
    services.flatpak.packages = [ "app.zen_browser.zen" ];
  };
}
