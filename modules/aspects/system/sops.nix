{ inputs, ... }:
{
  flake.modules.nixos.sops = {
    imports = [ inputs.sops-nix.nixosModules.sops ];
    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  };
}
