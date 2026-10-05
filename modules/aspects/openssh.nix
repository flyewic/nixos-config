{ ... }:
{
  flake.modules.nixos.openssh = {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };

  flake.modules.homeManager.openssh = {
    programs.ssh = {
      enable = true;
      # Home-manager will drop the implicit defaults. Set real settings here later.
      enableDefaultConfig = false;
    };
  };
}
