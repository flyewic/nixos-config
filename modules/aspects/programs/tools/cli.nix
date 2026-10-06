{ ... }:
{
  flake.modules.nixos.cli = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      ripgrep
      glow
      duf
      glances
      wl-clipboard
      just
    ];
  };
}
