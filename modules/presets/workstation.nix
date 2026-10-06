{ inputs, ... }:
{
  flake.modules.nixos.workstation = {
    imports = with inputs.self.modules.nixos; [
      common
      dev
      graphical
      nvidia
      steam
      faugus
      lutris
      heroic
      protonplus
      goverlay
      mangohud
      prismlauncher
      gnome-keyring
      printing
      bluetooth
      mullvad
      greetd
      easyeffects
    ];
  };

  flake.modules.homeManager.workstation = {
    imports = with inputs.self.modules.homeManager; [
      common
      dev
      graphical
      easyeffects
    ];
  };
}
