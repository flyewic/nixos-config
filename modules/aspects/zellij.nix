{ ... }:
{
  flake.modules.homeManager.zellij = {
    programs.zellij = {
      enable = true;
      # The old config.kdl is a zellij dump with clear-defaults. These are
      # the options that differ from the built-in config. Fish integration
      # stays off because ghostty's startup.sh is what attaches the session.
      enableFishIntegration = false;
      settings = {
        theme = "darkly";
        default_mode = "locked";
        session_serialization = false;
        show_startup_tips = false;
      };
      themes = {
        darkly = ./zellij/themes/darkly.kdl;
        otto = ./zellij/themes/otto.kdl;
      };
    };
  };
}
