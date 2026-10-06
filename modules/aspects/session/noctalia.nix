{ inputs, ... }:
{
  flake.modules.nixos.noctalia = {
    services.upower.enable = true;
  };

  flake.modules.homeManager.noctalia = {
    imports = [ inputs.noctalia.homeModules.default ];
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };
  };
}
