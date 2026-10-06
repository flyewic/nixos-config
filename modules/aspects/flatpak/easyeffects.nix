{ ... }:
{
  flake.modules.nixos.easyeffects = {
    services.flatpak.packages = [ "com.github.wwmm.easyeffects" ];
  };

  flake.modules.homeManager.easyeffects =
    { lib, pkgs, ... }:
    let
      # Flatpak data dir. The filename stem is the preset name.
      data = ".var/app/com.github.wwmm.easyeffects/data/easyeffects";
      kwriteconfig6 = "${pkgs.kdePackages.kconfig}/bin/kwriteconfig6";
    in
    {
      home.file."${data}/input/Input.json".source = ./easyeffects/Input.json;
      home.file."${data}/output/Output.json".source = ./easyeffects/Output.json;

      # Startup restores the last loaded name. Fallback covers a device with no autoload rule.
      home.activation.easyeffectsPresets = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        rc="$HOME/.var/app/com.github.wwmm.easyeffects/config/easyeffects/db/easyeffectsrc"
        run mkdir -p "$(dirname "$rc")"
        if [[ -L $rc ]]; then
          run rm "$rc"
        fi
        run ${kwriteconfig6} --file "$rc" --group Presets --key lastLoadedInputPreset -- Input
        run ${kwriteconfig6} --file "$rc" --group Presets --key lastLoadedOutputPreset -- Output
        run ${kwriteconfig6} --file "$rc" --group Window --key inputAutoloadingUsesFallback --type bool -- true
        run ${kwriteconfig6} --file "$rc" --group Window --key outputAutoloadingUsesFallback --type bool -- true
        run ${kwriteconfig6} --file "$rc" --group Window --key inputAutoloadingFallbackPreset -- Input
        run ${kwriteconfig6} --file "$rc" --group Window --key outputAutoloadingFallbackPreset -- Output
      '';
    };
}
