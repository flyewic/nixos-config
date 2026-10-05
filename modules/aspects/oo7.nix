{ lib, ... }:
{
  flake.modules.nixos.oo7 = {
    services.oo7.enable = true;
    # niri's module turns gnome-keyring on with mkDefault. Both daemons
    # claim org.freedesktop.secrets.
    services.gnome.gnome-keyring.enable = false;

    # Defining config.Hyprland replaces the portals.conf shipped with Hyprland,
    # which is only `default=hyprland;gtk`. oo7-portal.portal is UseIn=gnome.
    xdg.portal.config = {
      Hyprland = {
        default = [
          "hyprland"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Secret" = lib.mkForce [ "oo7-portal" ];
      };
      niri."org.freedesktop.impl.portal.Secret" = lib.mkForce [ "oo7-portal" ];
      river."org.freedesktop.impl.portal.Secret" = lib.mkForce [ "oo7-portal" ];
    };
  };
}
