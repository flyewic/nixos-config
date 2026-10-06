{ inputs, ... }:
{
  flake.modules.nixos.nix = {
    nixpkgs.hostPlatform = "x86_64-linux";
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Flake-only: no channels. Without this the default NIX_PATH points at
      # /nix/var/nix/profiles/per-user/root/channels, which is never created,
      # so every nix command warns. Point <nixpkgs> at the pinned input instead.
      nix-path = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
    };
    nix.channel.enable = false;
    # nh clean is the collector. These settings are the fallback if nh is dropped.
    nix.gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
