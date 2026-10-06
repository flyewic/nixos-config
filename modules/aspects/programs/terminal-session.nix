{ ... }:
{
  # The shared terminal startup script: attach the zellij session, then hand off
  # to herdr when a pane writes the handoff file. ghostty and kitty both point
  # their shells at this one installed path, so neither owns the other.
  flake.modules.homeManager."terminal-session" = {
    xdg.configFile."terminal-session/startup.sh" = {
      source = ./terminal-session/startup.sh;
      executable = true;
    };
  };
}
