{ ... }:
{
  flake.modules.homeManager.herdr = {
    programs.herdr = {
      enable = true;
      settings = {
        onboarding = false;
        keys = {
          focus_pane_left = [ "alt+left" ];
          focus_pane_down = [ "alt+down" ];
          focus_pane_up = [ "alt+up" ];
          focus_pane_right = [ "alt+right" ];
          previous_tab = [ "alt+shift+left" ];
          next_tab = [ "alt+shift+right" ];
          new_tab = [ "alt+t" ];
          split_vertical = [ "alt+shift+n" ];
          close_pane = [ "alt+x" ];
          previous_agent = [ "alt+shift+up" ];
          next_agent = [ "alt+shift+down" ];
          previous_workspace = [ "ctrl+alt+up" ];
          next_workspace = [ "ctrl+alt+down" ];
          new_workspace = [ "alt+s" ];
          rename_workspace = [ "alt+shift+s" ];
          rename_pane = [ "alt+r" ];
          rename_tab = [ "alt+shift+r" ];
        };
        ui = {
          agent_panel_sort = "priority";
          status_indicators = "dots";
          show_agent_labels_on_pane_borders = true;
          sound.enabled = false;
          toast.delivery = "off";
        };
      };
    };
  };
}
