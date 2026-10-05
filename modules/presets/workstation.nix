{ inputs, ... }:
{
  flake.modules.nixos.workstation = {
    imports = with inputs.self.modules.nixos; [
      common
      dev
      graphical
      nvidia
      steam
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
