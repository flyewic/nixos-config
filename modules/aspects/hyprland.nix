{ ... }:
{
  flake.modules.nixos.hyprland =
    { config, lib, ... }:
    {
      programs.hyprland.enable = true;
      security.pam.services.hyprlock = { };
      environment.sessionVariables = lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };
    };

  flake.modules.homeManager.hyprland = {
    wayland.windowManager.hyprland = {
      enable = true;
      # Empty settings plus the default systemd integration warns at eval.
      # Turn systemd back on when monitors and binds exist.
      systemd.enable = false;
      # TODO: monitors, binds, nvidia cursor
    };
  };
}
