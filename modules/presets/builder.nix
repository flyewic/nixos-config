{ inputs, ... }:
{
  flake.modules.nixos.builder = {
    imports = with inputs.self.modules.nixos; [
      common
      dev
    ];
    nix.settings.trusted-users = [
      "root"
      "@wheel"
    ];
  };

  flake.modules.homeManager.builder = {
    imports = with inputs.self.modules.homeManager; [
      common
      dev
    ];
  };
}
