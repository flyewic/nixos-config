{ ... }:
{
  # Stub. Nothing imports this until a host sets the tailnet name as its colmena target.
  flake.modules.nixos.tailscale = {
    # TODO: services.tailscale.enable per host
  };
}
