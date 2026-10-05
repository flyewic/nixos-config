{ inputs, ... }:
{
  flake.modules.nixos.graphical = {
    imports = with inputs.self.modules.nixos; [ pipewire ];
    services.xserver.enable = false;
    xdg.portal.enable = true;
  };

  flake.modules.homeManager.graphical = {
    # TODO: fonts, cursor, gtk theme once a compositor is chosen
  };
}
