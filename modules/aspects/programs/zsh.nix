{ ... }:
{
  flake.modules.nixos.zsh = {
    programs.zsh.enable = true;
  };

  flake.modules.homeManager.zsh = {
    programs.zsh.enable = true;
  };
}
