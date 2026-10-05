{ inputs, ... }:
{
  flake.modules.nixos.workstation = {
    imports = with inputs.self.modules.nixos; [
      common
      dev
      graphical
      nvidia
      steam
      gnome-keyring
    ];
  };

  flake.modules.homeManager.workstation = {
    imports = with inputs.self.modules.homeManager; [
      common
      dev
      graphical
    ];
  };
}
