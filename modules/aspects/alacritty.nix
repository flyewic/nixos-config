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
          opacity = 0.8;
          class = {
            instance = "Alacritty";
            general = "Alacritty";
          };
          decorations_theme_variant = "Dark";
        };

        scrolling = {
          history = 10000;
          multiplier = 3;
        };

        font = {
          normal = {
            family = "monospace";
            style = "Regular";
          };
          bold = {
            family = "monospace";
            style = "Bold";
          };
          italic = {
            family = "monospace";
            style = "Italic";
          };
          bold_italic = {
            family = "monospace";
            style = "Bold Italic";
          };
          size = 12.0;
        };

        colors = {
          draw_bold_text_with_bright_colors = true;
          primary = {
            background = "0x2E3440";
            foreground = "0xD8DEE9";
          };
          normal = {
            black = "0x3B4252";
            red = "0xBF616A";
            green = "0xA3BE8C";
            yellow = "0xEBCB8B";
            blue = "0x81A1C1";
            magenta = "0xB48EAD";
            cyan = "0x88C0D0";
            white = "0xE5E9F0";
          };
          bright = {
            black = "0x4C566A";
            red = "0xBF616A";
            green = "0xA3BE8C";
            yellow = "0xEBCB8B";
            blue = "0x81A1C1";
            magenta = "0xB48EAD";
            cyan = "0x8FBCBB";
            white = "0xECEFF4";
          };
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
