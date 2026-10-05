{ ... }:
{
  flake.modules.homeManager.kitty =
    { config, ... }:
    let
      # Ghostty owns startup.sh: attach zellij, then exec herdr on handoff.
      startup = "${config.xdg.configHome}/ghostty/startup.sh";

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
        background = "#222222";
        foreground = "#f1f1f1";
        cursor = "#3daee9";
        cursor_text_color = "#222222";
        selection_background = "#1b91d5";
        selection_foreground = "#fcfcfc";
        color0 = "#232627";
        color1 = "#da4453";
        color2 = "#24ad59";
        color3 = "#f67400";
        color4 = "#3daee9";
        color5 = "#8e44ad";
        color6 = "#00a1ec";
        color7 = "#f1f1f1";
        color8 = "#7f8c8d";
        color9 = "#f6747d";
        color10 = "#5ad47a";
        color11 = "#ffa040";
        color12 = "#6ec7f7";
        color13 = "#b06bd0";
        color14 = "#33c3ec";
        color15 = "#ffffff";
        tab_bar_background = "#1c1c1c";
        active_tab_background = "#3daee9";
        active_tab_foreground = "#222222";
        inactive_tab_background = "#2c2c2c";
        inactive_tab_foreground = "#cccccc";
      };
    in
    {
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
