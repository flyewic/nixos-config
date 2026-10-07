{ ... }:
{
  flake.modules.nixos.git = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.git ];
  };

  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      settings.user = {
        name = "flyewic";
        email = "22092995+flyewic@users.noreply.github.com";
      };
    };
  };
}
