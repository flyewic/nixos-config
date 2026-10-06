{ config, ... }:
{
  flake.modules.nixos.river =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      environment.systemPackages = [ pkgs.river ];
      environment.sessionVariables = lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };
    };

  flake.modules.homeManager.river =
    { lib, ... }:
    {
      # init is ported from the curated niri config. The keyboard option fills
      # the xkb layout.
      xdg.configFile."river/init" = {
        text =
          lib.replaceStrings
            [ "@KB_LAYOUT@" "@KB_VARIANT@" ]
            [ config.keyboard.layout config.keyboard.variant ]
            (builtins.readFile ./river/init);
        executable = true;
      };
    };
}
