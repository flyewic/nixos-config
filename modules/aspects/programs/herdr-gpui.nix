{ inputs, ... }:
{
  flake.modules.nixos.herdr-gpui = { pkgs, ... }: {
    nixpkgs.overlays = [ inputs.herdr-gpui.overlays.default ];
    environment.systemPackages = [ pkgs.herdr-gpui ];
  };
}
