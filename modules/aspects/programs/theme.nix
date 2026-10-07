{ inputs, ... }:
{
  flake.modules.nixos.theme =
    { pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      # Stylix is the single source of truth for colors and fonts. It writes
      # the app configs through home-manager, so Noctalia's runtime templates
      # are redundant for external apps.
      stylix = {
        enable = true;
        polarity = "dark";
        base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
        fonts = {
          monospace = {
            name = "JetBrainsMono Nerd Font";
            package = pkgs.nerd-fonts."jetbrains-mono";
          };
          sizes.terminal = 13;
        };
      };

      # rofi is not installed; its target still sets a renamed option and warns.
      home-manager.sharedModules = [
        { stylix.targets.rofi.enable = false; }
      ];
    };
}
