{ inputs, ... }:
{
  flake.modules.nixos.apps = {
    imports = with inputs.self.modules.nixos; [
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
  };
}
