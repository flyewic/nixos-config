{ ... }:
{
  flake.modules.homeManager.alacritty = {
    programs.alacritty = {
      enable = true;
      settings = {
        general.live_config_reload = true;

        env = {
          TERM = "xterm-256color";
          WINIT_X11_SCALE_FACTOR = "1.0";
        };

        window = {
          dimensions = {
            columns = 100;
            lines = 30;
          };
          dynamic_padding = true;
          decorations = "Full";
          class = {
            instance = "Alacritty";
            general = "Alacritty";
          };
        };

        scrolling = {
          history = 10000;
          multiplier = 3;
        };

        colors = {
          draw_bold_text_with_bright_colors = true;
        };

        selection = {
          semantic_escape_chars = ",│`|:\"' ()[]{}<>\t";
          save_to_clipboard = true;
        };

        cursor = {
          style = {
            shape = "Underline";
            blinking = "Off";
          };
          unfocused_hollow = true;
          thickness = 0.15;
        };

        mouse = {
          hide_when_typing = true;
          bindings = [
            {
              mouse = "Middle";
              mods = "None";
              action = "PasteSelection";
            }
          ];
        };
      };
    };
  };
}
