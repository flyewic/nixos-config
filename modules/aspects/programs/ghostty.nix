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
        background-blur = true;
        window-height = 50;
        window-width = 130;
      };
    };
  };
}
