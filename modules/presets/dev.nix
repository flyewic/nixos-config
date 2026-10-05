{ ... }:
{
  flake.modules.nixos.dev = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ git ];
    # TODO: editor and build tools
  };

  flake.modules.homeManager.dev = {
    programs.git.enable = true;
    # TODO: fish or nushell. The login shell is set in this preset, not in users.
  };
}
