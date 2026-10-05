{ ... }:
{
  flake.modules.nixos.keyboard = {
    # Swedish layout, no dead keys. The console keymap includes sv-latin1 and
    # removes its dead keys; X11 gets the nodeadkeys variant. Wayland
    # compositors do not read the xkb options, so the Hyprland aspect also sets
    # input:kb_layout.
    console.keyMap = ./keyboard/sv-latin1-nodeadkeys.map;
    services.xserver.xkb = {
      layout = "se";
      variant = "nodeadkeys";
    };
    environment.sessionVariables = {
      XKB_DEFAULT_LAYOUT = "se";
      XKB_DEFAULT_VARIANT = "nodeadkeys";
    };
  };
}
