{ inputs, ... }:
{
  flake.modules.nixos.zol = { lib, ... }: {
    imports = [ inputs.zol.nixosModules.default ];

    # zol's binary is proprietary, so nixpkgs blocks it until it is allowed.
    # Allow this one package rather than every unfree package.
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "zol" ];

    programs.zol.enable = true;
  };
}
