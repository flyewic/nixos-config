{ ... }:
{
  flake.modules.nixos.signal = {
    services.flatpak.packages = [ "org.signal.Signal" ];
  };
}
