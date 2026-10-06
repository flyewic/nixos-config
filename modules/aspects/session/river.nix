{ ... }:
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

  flake.modules.homeManager.river = {
    xdg.configFile."river/init".source = ./river/init;
  };
}
