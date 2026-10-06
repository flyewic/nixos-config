{ config, ... }:
{
  flake.modules.nixos.hyprland =
    { config, lib, ... }:
    {
      programs.hyprland = {
        enable = true;
        # start-hyprland routes the session through UWSM. Without this the
        # uwsm systemd units are absent and the session exits immediately.
        withUWSM = true;
      };
      security.pam.services.hyprlock = { };
      environment.sessionVariables = lib.mkIf (lib.elem "nvidia" config.services.xserver.videoDrivers) {
        LIBVA_DRIVER_NAME = "nvidia";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };
    };

  flake.modules.homeManager.hyprland =
    { lib, ... }:
    {
      wayland.windowManager.hyprland = {
        enable = true;
        # UWSM starts graphical-session.target; this imports the Wayland env and
        # starts the session target so systemd user services (noctalia) come up.
        systemd.enable = true;
        # config.lua is ported from the curated niri config. The keyboard option
        # fills the xkb layout so it does not depend on locale1.
        extraConfig =
          lib.replaceStrings
            [ "@KB_LAYOUT@" "@KB_VARIANT@" ]
            [ config.keyboard.layout config.keyboard.variant ]
            (builtins.readFile ./hyprland/config.lua);
      };
    };
}
