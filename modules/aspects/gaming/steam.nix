{ ... }:
{
  flake.modules.nixos.steam = {
    nixpkgs.config.allowUnfree = true;
    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    # Library path is /var/games from the desktop disko layout.
  };
}
