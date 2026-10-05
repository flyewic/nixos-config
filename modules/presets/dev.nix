{ inputs, ... }:
{
  flake.modules.nixos.dev = { pkgs, ... }: {
    imports = with inputs.self.modules.nixos; [ fish ];
    environment.systemPackages = with pkgs; [ git ];
    # The login shell is chosen here, not in the users aspect.
    users.defaultUserShell = pkgs.fish;
    # TODO: editor and build tools
  };

  flake.modules.homeManager.dev = {
    imports = with inputs.self.modules.homeManager; [
      fish
      ghostty
      kitty
      alacritty
      zellij
      herdr
    ];
    programs.git.enable = true;
  };
}
