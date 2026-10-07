{ inputs, ... }:
{
  flake.modules.nixos.zol =
    { lib, pkgs, ... }:
    let
      # zol's window backend (wio) dlopens its window-system libraries instead of
      # linking them, so autoPatchelfHook cannot see them. The upstream package
      # only puts the Vulkan loader on the RPATH, which is why zol starts but
      # cannot connect to Wayland or X11. Add every dlopen'd backend here.
      backendLibs = with pkgs; [
        libdecor
        libx11
        libxcursor
        libxext
        libxkbcommon
        libxrandr
        wayland
      ];

      zol = pkgs.zol.overrideAttrs (old: {
        runtimeDependencies = (old.runtimeDependencies or [ ]) ++ backendLibs;
      });
    in
    {
      imports = [ inputs.zol.nixosModules.default ];

      # zol's binary is proprietary, so nixpkgs blocks it until it is allowed.
      # Allow this one package rather than every unfree package.
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "zol" ];

      # The overlay supplies `pkgs.zol`, built from the host's package set so the
      # unfree predicate above applies to it.
      nixpkgs.overlays = [ inputs.zol.overlays.default ];

      programs.zol = {
        enable = true;
        package = zol;
      };
    };
}
