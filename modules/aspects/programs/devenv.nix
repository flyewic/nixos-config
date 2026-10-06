{ ... }:
{
  flake.modules.nixos.devenv = { pkgs, ... }: {
    environment.systemPackages = [
      pkgs.devenv
      pkgs.cachix
    ];
    # Prebuilt devenv environments are substituted from its public cache.
    nix.settings = {
      extra-substituters = [ "https://devenv.cachix.org" ];
      extra-trusted-public-keys = [
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };
  };

  flake.modules.homeManager.devenv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
