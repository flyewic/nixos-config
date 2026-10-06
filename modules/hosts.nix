{
  inputs,
  self,
  config,
  ...
}:
let
  lib = inputs.nixpkgs.lib;

  # Wiring every host shares. It lives here, not in each host file, so the two
  # consumers below evaluate the exact same base. `deploymentOptions` must stay
  # imported for `nixos-rebuild` to evaluate `deployment.*`; colmena gets the
  # same base through `asNode`.
  hostBase = {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.colmena.nixosModules.deploymentOptions
      inputs.home-manager.nixosModules.home-manager
    ];
    system.stateVersion = config.stateVersion;
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  mkNixos = modules: lib.nixosSystem { modules = [ hostBase ] ++ modules; };

  # One entry per machine: its host module(s) and whether colmena deploys it.
  # `nixosConfigurations` and `colmenaHive` both derive from this map, so a new
  # machine is one entry, not two lists that can drift apart.
  machines = {
    desktop = {
      deployable = true;
      modules = [ self.modules.nixos."desktop-host" ];
    };
    laptop = {
      deployable = true;
      modules = [ self.modules.nixos."laptop-host" ];
    };
    "laptop-nvidia" = {
      deployable = true;
      modules = [ self.modules.nixos."laptop-nvidia-host" ];
    };
    # Local QEMU test box. It has no deployment block, so colmena skips it and
    # its image lives only as long as the run script.
    vm = {
      deployable = false;
      modules = [ self.modules.nixos."vm-host" ];
    };
  };

  asNode = m: { imports = [ hostBase ] ++ m.modules; };
in
{
  flake.nixosConfigurations = lib.mapAttrs (_: m: mkNixos m.modules) machines;

  flake.colmenaHive = inputs.colmena.lib.makeHive (
    {
      meta.nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    }
    // lib.mapAttrs (_: asNode) (lib.filterAttrs (_: m: m.deployable) machines)
  );
}
