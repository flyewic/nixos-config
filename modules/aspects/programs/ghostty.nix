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
          theme = "darkly";
          background-opacity = 1;
          background-blur = true;
          command = startup;
          font-family = "JetBrainsMono Nerd Font";
          font-size = 13;
          window-height = 50;
          window-width = 130;
        };
        themes = {
          darkly = {
            background = "#222222";
            foreground = "#eff0f1";
            cursor-color = "#3478da";
            selection-background = "#1b91d5";
            selection-foreground = "#f1f1f1";
            palette = [
              "0=#222222"
              "1=#da4453"
              "2=#24ad59"
              "3=#f67400"
              "4=#3daee9"
              "5=#73739e"
              "6=#00a1ec"
              "7=#f1f1f1"
              "8=#909090"
              "9=#ed1515"
              "10=#11d116"
              "11=#c9ce3b"
              "12=#1d99f3"
              "13=#9090c0"
              "14=#3daee6"
              "15=#ffffff"
            ];
          };
          otto = {
            background = "#2c3746";
            foreground = "#fefefe";
            cursor-color = "#f77067";
            selection-background = "#f7c068";
            selection-foreground = "#2c3746";
            palette = [
              "0=#2c3746"
              "1=#f77067"
              "2=#43cdbd"
              "3=#f7c068"
              "4=#3daee9"
              "5=#9c53c6"
              "6=#5f7dcd"
              "7=#fefefe"
              "8=#7f8c8d"
              "9=#f9948d"
              "10=#72dacd"
              "11=#f9d08e"
              "12=#6ec2ef"
              "13=#b57ed4"
              "14=#879ed9"
              "15=#ffffff"
            ];
          };
          dankcolors = {
            background = "#131314";
            foreground = "#e4e2e3";
            cursor-color = "#bdc7d4";
            selection-background = "#3e4852";
            selection-foreground = "#e4e2e3";
            palette = [
              "0=#131314"
              "1=#f36d94"
              "2=#6ad478"
              "3=#fff772"
              "4=#afbac9"
              "5=#4e5762"
              "6=#bdc7d4"
              "7=#d1d7de"
              "8=#7f8489"
              "9=#ff9fbb"
              "10=#a5feb1"
              "11=#fffaa5"
              "12=#d3dde9"
              "13=#ebf4ff"
              "14=#f2f7ff"
              "15=#f8fbff"
            ];
          };
        };
      };
    };
}
