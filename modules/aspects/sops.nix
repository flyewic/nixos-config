{ inputs, ... }:
{
  flake.modules.nixos.sops = {
    imports = [ inputs.sops-nix.nixosModules.sops ];
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    # TODO: sops.defaultSopsFile once secrets/secrets.yaml exists.
    # A path to a missing file fails evaluation. Add secrets after the first boot.
  };
}
