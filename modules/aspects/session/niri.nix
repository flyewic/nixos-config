{ config, ... }:
{
  flake.modules.nixos.niri =
    { config, lib, ... }:
    {
      programs.niri.enable = true;
      environment.sessionVariables = lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };
    };

  flake.modules.homeManager.niri =
    { lib, ... }:
    {
      wayland.windowManager.niri = {
        enable = true;
        # config.kdl is curated from the old DMS setup; shell actions go through
        # noctalia. The keyboard option fills the xkb layout so niri does not
        # depend on org.freedesktop.locale1.
        extraConfig =
          lib.replaceStrings
            [ "@KB_LAYOUT@" "@KB_VARIANT@" ]
            [ config.keyboard.layout config.keyboard.variant ]
            (builtins.readFile ./niri/config.kdl);
      };
    };
}
