{ inputs, ... }:
{
  flake.modules.nixos.server = {
    imports = with inputs.self.modules.nixos; [ common ];
  };

  flake.modules.homeManager.server = {
    imports = with inputs.self.modules.homeManager; [ common ];
  };
}
