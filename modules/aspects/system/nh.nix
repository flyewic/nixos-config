{ config, ... }:
{
  flake.modules.nixos.nh = {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 2";
      flake = "/home/${config.username}/nixos-config";
    };
  };
}
