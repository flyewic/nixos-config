{ ... }:
{
  flake.modules.homeManager.fuzzel = {
    programs.fuzzel = {
      enable = true;
      settings = {
        border = {
          width = 1;
          radius = 10;
        };
      };
    };
  };
}
