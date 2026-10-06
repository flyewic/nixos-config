{ ... }:
let
  look = {
    font_family = "JetBrainsMono Nerd Font";
    font_size = 13;
    strip_trailing_spaces = "smart";
    scrollback_lines = 20000;
    tab_bar_style = "powerline";
    tab_bar_edge = "top";
    cursor_trail = 1;
    cursor_trail_decay = "0.1 0.2";
    cursor_trail_start_threshold = 2;
  };
in
{
  flake.modules.homeManager.kitty = {
    programs.kitty = {
      enable = true;
      settings = look;
      quickAccessTerminalConfig = look // {
        kitty_conf = "quick-access-terminal.conf";
      };
    };
  };
}
