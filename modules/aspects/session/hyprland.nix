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
        # Systemd integration stays off until the session targets are set up.
        systemd.enable = false;

        # Lua config (the 26.05 default). `mod` is a Lua local, so a host
        # overrides the modifier for every bind below by forcing settings.mod.
        settings = {
          mod = {
            _var = "SUPER";
          };

          config = {
            input = {
              kb_layout = config.keyboard.layout;
              kb_variant = config.keyboard.variant;
            };
          };

          bind = [
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + RETURN"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("kitty")'')
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + D"'')
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("fuzzel")'')
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + Q"'')
                (lib.generators.mkLuaInline "hl.dsp.window.close()")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + F"'')
                (lib.generators.mkLuaInline "hl.dsp.window.fullscreen()")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + V"'')
                (lib.generators.mkLuaInline "hl.dsp.window.float()")
              ];
            }
            {
              _args = [
                (lib.generators.mkLuaInline ''mod .. " + M"'')
                (lib.generators.mkLuaInline "hl.dsp.exit()")
              ];
            }
          ];
          # TODO: monitors, workspace binds, nvidia cursor
        };
      };
    };
}
