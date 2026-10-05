{ ... }:
{
  flake.modules.nixos.nix = {
    nixpkgs.hostPlatform = "x86_64-linux";
    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    # nh clean is the collector. These settings are the fallback if nh is dropped.
    nix.gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
