{ inputs, ... }:
{
  flake.modules.nixos.laptop = {
    imports = with inputs.self.modules.nixos; [
      common
      dev
      graphical
      gnome-keyring
    ];
    services.power-profiles-daemon.enable = true;
    # TODO: tlp vs power-profiles-daemon, wireless backend
  };

  flake.modules.homeManager.laptop = {
    imports = with inputs.self.modules.homeManager; [
      common
      dev
      graphical
    ];
  };
}
