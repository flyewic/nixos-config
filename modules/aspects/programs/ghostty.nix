{ ... }:
{
  flake.modules.homeManager.ghostty = {
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
        font-family = "JetBrainsMono Nerd Font";
        font-size = 13;
        window-height = 50;
        window-width = 130;
      };
    };
  };
}
