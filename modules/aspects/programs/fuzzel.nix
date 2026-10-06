{ ... }:
{
  flake.modules.homeManager.fuzzel = {
    programs.fuzzel = {
      enable = true;
      settings = {
        colors = {
          background = "222222dd";
          text = "eff0f1ff";
          match = "3daee9ff";
          selection = "1b91d5ff";
          selection-text = "f1f1f1ff";
          selection-match = "ffffffff";
          border = "3478daff";
        };
        border = {
          width = 1;
          radius = 10;
        };
      };
    };
  };
}
