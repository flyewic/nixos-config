{ ... }:
{
  flake.modules.nixos.sublime = { pkgs, ... }: {
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = [
      pkgs.sublime4
      pkgs.sublime-merge
    ];
  };
}
