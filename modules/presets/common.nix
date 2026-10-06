{ inputs, ... }:
{
  flake.modules.nixos.common = {
    imports = with inputs.self.modules.nixos; [
      nix
      kernel
      users
      locale
      keyboard
      network
      openssh
      sops
      nh
      fastfetch
      btop
      cli
    ];
  };

  flake.modules.homeManager.common = {
    imports = with inputs.self.modules.homeManager; [
      users
      openssh
    ];
  };
}
