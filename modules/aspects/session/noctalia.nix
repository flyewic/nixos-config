{ ... }:
{
  flake.modules.nixos.noctalia = {
    services.upower.enable = true;
  };

  flake.modules.homeManager.noctalia = {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      # Stylix owns app colors and fonts. Keep Noctalia from writing app configs
      # that home-manager manages; it themes only its own shell.
      settings.theme.templates = {
        enable_builtin_templates = false;
        enable_community_templates = false;
      };
    };
  };
}
