{ inputs, ... }:
{
  flake.modules.homeManager.ghostty =
    { config, ... }:
    let
      # terminal-session owns the script so neither terminal imports the other.
      startup = "${config.xdg.configHome}/terminal-session/startup.sh";
    in
    {
      imports = [ inputs.self.modules.homeManager."terminal-session" ];

      programs.ghostty = {
        enable = true;
        settings = {
          keybind = [
            "ctrl+z=close_surface"
            "ctrl+n=new_split:right"
            "ctrl+d=ignore"
          ];
          background-opacity = 1;
          background-blur = true;
          command = startup;
          font-family = "JetBrainsMono Nerd Font";
          font-size = 13;
          window-height = 50;
          window-width = 130;
        };
      };
    };
}
