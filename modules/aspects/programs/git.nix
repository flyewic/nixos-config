{ ... }:
{
  flake.modules.nixos.git = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.git ];
  };

  flake.modules.homeManager.git = {
    programs.git = {
      enable = true;
      userName = "flyewic";
      userEmail = "flyewic@gmail.com";
    };
  };
}
