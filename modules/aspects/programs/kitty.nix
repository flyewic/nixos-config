{ inputs, ... }:
{
  flake.modules.homeManager.kitty =
    { config, ... }:
    let
      # terminal-session owns startup.sh: attach zellij, then exec herdr.
      startup = "${config.xdg.configHome}/terminal-session/startup.sh";

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
      imports = [ inputs.self.modules.homeManager."terminal-session" ];

      programs.kitty = {
        enable = true;
        settings = look // {
          shell = startup;
        };
        quickAccessTerminalConfig = look // {
          kitty_conf = "quick-access-terminal.conf";
          shell = "zellij attach --create dropdown";
        };
      };
    };
}
