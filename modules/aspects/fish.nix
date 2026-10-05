{ lib, ... }:
let
  functionDir = ./fish/functions;
  functionFiles = lib.filterAttrs (_: type: type == "regular") (builtins.readDir functionDir);
in
{
  flake.modules.nixos.fish = {
    programs.fish.enable = true;
  };

  flake.modules.homeManager.fish =
    { pkgs, ... }:
    {
      programs.fish = {
        enable = true;
        # The CachyOS fish config is not copied. Installer trees (bun, zvm,
        # sdkman, opencode, grok) stay outside this repo.
        shellInit = ''
          set -gx SSH_AUTH_SOCK "$HOME/.bitwarden-ssh-agent.sock"
        '';
        interactiveShellInit = ''
          set fish_greeting
        '';
      };

      programs.zoxide.enable = true;

      # Real function files. programs.fish.functions wraps `body` in
      # `function name ... end`, which would double-wrap these.
      xdg.configFile = lib.mapAttrs' (name: _: {
        name = "fish/functions/${name}";
        value.source = functionDir + "/${name}";
      }) functionFiles;

      # gwt prints a path. fwt opens a nested shell in the chosen worktree:
      # a child process cannot cd the fish that launched it.
      home.packages = with pkgs; [
        bat
        fzf
        pkgs."flow-control"
        (writeShellApplication {
          name = "gwt";
          runtimeInputs = [
            coreutils
            git
          ];
          text = builtins.readFile ./fish/gwt.sh;
        })
        (writeShellApplication {
          name = "fwt";
          runtimeInputs = [
            coreutils
            fzf
            gawk
            git
          ];
          text = builtins.readFile ./fish/fwt.sh;
        })
      ];
    };
}
