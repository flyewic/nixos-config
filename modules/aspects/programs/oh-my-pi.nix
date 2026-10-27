{ inputs, ... }:
{
  flake.modules.homeManager.oh-my-pi =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.programs.omp;

      completions = pkgs.runCommandLocal "omp-completions" { nativeBuildInputs = [ cfg.package ]; } ''
        mkdir -p $out/fish/completions $out/bash-completion/completions $out/zsh/site-functions
        omp completions fish > $out/fish/completions/omp.fish
        omp completions bash > $out/bash-completion/completions/omp
        omp completions zsh > $out/zsh/site-functions/_omp
      '';
    in
    {
      imports = [ inputs.omp.homeManagerModules.default ];

      programs.omp = {
        enable = true;
        settings.startup.quiet = true;
      };

      xdg.configFile."fish/completions/omp.fish".source = "${completions}/fish/completions/omp.fish";

      xdg.dataFile."bash-completion/completions/omp".source =
        "${completions}/bash-completion/completions/omp";

      xdg.dataFile."zsh/site-functions/_omp".source = "${completions}/zsh/site-functions/_omp";

      programs.zsh.initContent = lib.mkOrder 550 ''
        fpath+=("${config.xdg.dataHome}/zsh/site-functions")
      '';
    };
}
