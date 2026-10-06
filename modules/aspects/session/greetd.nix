{ ... }:
{
  # A text login manager. tuigreet lists the installed Wayland sessions, so this
  # aspect stays compositor-agnostic: the host picks hyprland, niri, or river and
  # the greeter offers whatever is present.
  flake.modules.nixos.greetd =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      services.greetd = {
        enable = true;
        useTextGreeter = true;
        settings.default_session.command = lib.concatStringsSep " " [
          (lib.getExe pkgs.tuigreet)
          "--time"
          "--remember"
          "--sessions"
          "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        ];
      };
    };
}
