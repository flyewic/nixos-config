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

  # useXkbConfig derives the console map from the xkb settings below, so
  # ckbcomp emits one self-contained map. A hand-written map that includes
  # "sv-latin1" does not load: kbd only resolves includes with a "" or
  # ".inc" suffix and never looks in i386/qwerty, so loadkeys fails and the
  # console keeps the built-in us layout. Wayland compositors ignore the
  # NixOS xkb options, so each compositor reads keyboard.layout and
  # keyboard.variant too. earlySetup puts this map in the initrd. udev
  # starts systemd-vconsole-setup on its own, so the LUKS units wait for
  # that service before the passphrase prompt.
  config.flake.modules.nixos.keyboard = {
    console.useXkbConfig = true;
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
