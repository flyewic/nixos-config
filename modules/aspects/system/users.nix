{ ... }:
let
  # TODO_USER: one username, shared by every host. Login shell is chosen in the dev preset.
  user = "TODO_USER";
in
{
  flake.modules.nixos.users = {
    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
    security.sudo.wheelNeedsPassword = true;
  };

  flake.modules.homeManager.users = {
    home.username = user;
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "26.05"; # release at first install; do not bump
  };
}
