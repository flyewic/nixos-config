{ inputs, self, ... }:
let
  # deploymentOptions stays on nixosSystem so `nixos-rebuild` can evaluate
  # deployment.*. Colmena evaluates the host module directly, so each host
  # imports the same modules again.
  mkNixos =
    modules:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.colmena.nixosModules.deploymentOptions
        inputs.home-manager.nixosModules.home-manager
      ]
      ++ modules;
    };
in
{
  flake.nixosConfigurations = {
    desktop = mkNixos [ self.modules.nixos.desktop ];
    laptop = mkNixos [ self.modules.nixos.laptop ];
  };

  flake.colmenaHive = inputs.colmena.lib.makeHive {
    meta.nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    desktop = self.modules.nixos.desktop;
    laptop = self.modules.nixos.laptop;
  };
}
