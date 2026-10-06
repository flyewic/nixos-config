{ config, lib, ... }:
{
  options.keyboard = {
    layout = lib.mkOption {
      type = lib.types.str;
      default = "se";
    };
    variant = lib.mkOption {
      type = lib.types.str;
      default = "nodeadkeys";
    };
  };

  # The console map is sv-latin1 with its dead keys removed. Wayland
  # compositors ignore the NixOS xkb options, so each compositor reads
  # keyboard.layout and keyboard.variant too.
  config.flake.modules.nixos.keyboard = {
    console.keyMap = ./keyboard/sv-latin1-nodeadkeys.map;
    services.xserver.xkb = {
      layout = config.keyboard.layout;
      variant = config.keyboard.variant;
    };
    environment.sessionVariables = {
      XKB_DEFAULT_LAYOUT = config.keyboard.layout;
      XKB_DEFAULT_VARIANT = config.keyboard.variant;
    };
  };
}
