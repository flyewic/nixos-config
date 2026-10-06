{ config, lib, ... }:
{
  options.username = lib.mkOption {
    type = lib.types.str;
    default = "flye";
  };

  options.stateVersion = lib.mkOption {
    type = lib.types.str;
    default = "26.05";
    description = "Shared stateVersion. A host installed on a later release sets its own.";
  };

  config = {
    flake.modules.nixos.users = {
      users.users.${config.username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
      security.sudo.wheelNeedsPassword = true;
    };

    flake.modules.homeManager.users = {
      home.username = config.username;
      home.homeDirectory = "/home/${config.username}";
      home.stateVersion = config.stateVersion;
    };
  };
}
