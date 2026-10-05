{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      # Force the full module system (including assertions) to evaluate without
      # building a host. `system.build.vm` is used as the target because the
      # `vm` host has no base disk layout; it evaluates the same modules for
      # the real hosts. The string context is discarded so this check does not
      # gain the system as a build input.
      checks = builtins.mapAttrs (
        name: cfg:
        pkgs.runCommandLocal "nixos-eval-${name}" { } ''
          echo ${builtins.unsafeDiscardStringContext cfg.config.system.build.vm.drvPath} > $out
        ''
      ) self.nixosConfigurations;
    };
}
