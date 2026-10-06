{ ... }:
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

  flake.modules.homeManager.niri = {
    programs.niri = {
      enable = true;
      # TODO: monitors, binds
    };
  };
}
