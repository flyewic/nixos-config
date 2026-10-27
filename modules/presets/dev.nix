{ inputs, ... }:
{
  flake.modules.nixos.dev = { pkgs, ... }: {
    imports = with inputs.self.modules.nixos; [
      fish
      zsh
      nushell
      git
      neovim
      zed
      zol
      opencode
      devtools
      devenv
      sublime
      kate
      micro
      vim
    ];
    # The login shell is chosen here, not in the users aspect.
    users.defaultUserShell = pkgs.fish;
    # TODO: build tools
  };

  flake.modules.homeManager.dev = {
    imports = with inputs.self.modules.homeManager; [
      fish
      zsh
      nushell
      git
      starship
      ghostty
      kitty
      alacritty
      zellij
      herdr
      oh-my-pi
      devenv
    ];
  };
}
