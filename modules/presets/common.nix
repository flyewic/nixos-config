{ inputs, ... }:
{
  flake.modules.nixos.common = {
    imports = with inputs.self.modules.nixos; [
      nix
      users
      locale
      keyboard
      network
      openssh
      sops
      nh
    ];
  };

  flake.modules.homeManager.common = {
    imports = with inputs.self.modules.homeManager; [
      users
      openssh
    ];
  };
}
