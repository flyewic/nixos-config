{ ... }:
{
  flake.modules.homeManager.herdr = {
    programs.herdr = {
      enable = true;
      settings = {
        onboarding = false;
        keys = {
          focus_pane_left = [
            "prefix+h"
            "alt+left"
          ];
          focus_pane_down = [ "prefix+j" ];
          focus_pane_up = [ "prefix+k" ];
          focus_pane_right = [
            "prefix+l"
            "alt+right"
          ];
          previous_tab = [
            "prefix+p"
            "alt+shift+left"
          ];
          next_tab = [
            "prefix+n"
            "alt+shift+right"
          ];
          new_tab = [
            "prefix+c"
            "alt+t"
          ];
          split_vertical = [
            "prefix+v"
            "alt+n"
          ];
          close_pane = [
            "prefix+x"
            "alt+x"
          ];
          previous_agent = [ "alt+up" ];
          next_agent = [ "alt+down" ];
          previous_workspace = [ "alt+shift+up" ];
          next_workspace = [ "alt+shift+down" ];
          # Keybinds for jhochenbaum.hunkdiff are kept. The plugin checkout is not.
          command = [
            {
              key = "prefix+shift+h";
              type = "plugin_action";
              command = "jhochenbaum.hunkdiff.review";
              description = "hunk: review changes";
            }
            {
              key = "prefix+shift+s";
              type = "plugin_action";
              command = "jhochenbaum.hunkdiff.send-review";
              description = "hunk: send review to agent";
            }
            {
              key = "prefix+shift+c";
              type = "plugin_action";
              command = "jhochenbaum.hunkdiff.review:commit";
              description = "hunk: review the last commit";
            }
            {
              key = "prefix+shift+a";
              type = "plugin_action";
              command = "jhochenbaum.hunkdiff.review:staged";
              description = "hunk: review staged changes";
            }
          ];
        };
        ui = {
          agent_panel_sort = "priority";
          status_indicators = "dots";
          show_agent_labels_on_pane_borders = true;
          sound.enabled = false;
          toast.delivery = "off";
        };
        theme = {
          name = "one-dark";
          auto_switch = false;
        };
      };
    };
  };
}
