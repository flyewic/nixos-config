{
  perSystem =
    { config, pkgs, ... }:
    {
      # Admin-machine tooling. NixOS hosts already carry these in the system
      # closure; this shell is for a non-NixOS checkout (and the VM workflow).
      devShells.default = pkgs.mkShell {
        packages = [
          config.treefmt.build.wrapper
          pkgs.age
          pkgs.colmena
          pkgs.just
          pkgs.nh
          pkgs.sops
          pkgs.ssh-to-age
        ];
      };
    };
}
