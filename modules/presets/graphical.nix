{ inputs, ... }:
{
  flake.modules.nixos.graphical = { pkgs, ... }: {
    imports = with inputs.self.modules.nixos; [
      pipewire
      flatpak
      bitwarden
      spotify
      goofcord
      signal
      zen
      opencode-desktop
      telegram-desktop
      thunderbird
      kdeconnect
      haruna
      qbittorrent
    ];
    services.xserver.enable = false;
    xdg.portal.enable = true;
    fonts.packages = [ pkgs.nerd-fonts."jetbrains-mono" ];
  };

  flake.modules.homeManager.graphical = {
    imports = with inputs.self.modules.homeManager; [ fuzzel ];
    # TODO: cursor, gtk theme once a compositor is chosen
  };
}
