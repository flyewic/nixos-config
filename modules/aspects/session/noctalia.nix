{ ... }:
{
  flake.modules.nixos.noctalia = {
    services.upower.enable = true;
  };

  flake.modules.homeManager.noctalia = {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };
  };
}
