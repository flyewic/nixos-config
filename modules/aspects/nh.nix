{ ... }:
{
  flake.modules.nixos.nh = {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 3";
      # TODO_USER: real checkout, or override per host.
      flake = "/home/TODO_USER/src/nixos";
    };
  };
}
