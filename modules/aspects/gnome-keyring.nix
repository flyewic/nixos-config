{ lib, ... }:
{
  flake.modules.nixos.gnome-keyring = {
    services.gnome.gnome-keyring.enable = true;

    # Defining config.Hyprland replaces the portals.conf shipped with Hyprland,
    # which is only `default=hyprland;gtk`. The secret portal file is UseIn=gnome.
    xdg.portal.config = {
      Hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      niri."org.freedesktop.impl.portal.Secret" = lib.mkDefault [ "gnome-keyring" ];
      river."org.freedesktop.impl.portal.Secret" = lib.mkDefault [ "gnome-keyring" ];
    };
  };
}
