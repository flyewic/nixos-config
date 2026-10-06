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
  # keyboard.layout and keyboard.variant too. earlySetup puts this map in
  # the initrd. udev starts systemd-vconsole-setup on its own, so the LUKS
  # units wait for that service before the passphrase prompt.
  config.flake.modules.nixos.keyboard = {
    console.keyMap = ./keyboard/sv-latin1-nodeadkeys.map;
    console.earlySetup = true;

    boot.initrd.systemd.services."systemd-cryptsetup@" = {
      overrideStrategy = "asDropin";
      enableDefaultPath = false;
      after = [ "systemd-vconsole-setup.service" ];
      wants = [ "systemd-vconsole-setup.service" ];
    };

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
