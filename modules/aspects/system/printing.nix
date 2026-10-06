{ ... }:
{
  flake.modules.nixos.printing = { pkgs, ... }: {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        hplip
        gutenprint
      ];
    };
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    environment.systemPackages = [ pkgs.system-config-printer ];
  };
}
