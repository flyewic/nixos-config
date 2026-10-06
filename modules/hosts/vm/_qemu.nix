# Host-private VM plumbing. The nixpkgs qemu expects NixOS's
# `/run/opengl-driver` for its GBM/EGL drivers. Built from a non-NixOS host
# that path is absent, so virgl fails and aquamarine (Hyprland) gets no
# renderer. Point qemu at the Nix Mesa instead. Harmless on a real NixOS host.
{ pkgs, ... }:
let
  qemuGlWrapper = pkgs.writeShellScript "qemu-system-x86_64" ''
    export GBM_BACKENDS_PATH=${pkgs.mesa}/lib/gbm
    export LIBGL_DRIVERS_PATH=${pkgs.mesa}/lib/dri
    export LD_LIBRARY_PATH=${pkgs.mesa}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
    exec ${pkgs.qemu}/bin/qemu-system-x86_64 "$@"
  '';

  qemuGl = pkgs.runCommand "qemu-gl" { } ''
    mkdir -p $out/bin
    for f in ${pkgs.qemu}/bin/*; do
      ln -s "$f" "$out/bin/$(basename "$f")"
    done
    rm -f $out/bin/qemu-system-x86_64
    cp ${qemuGlWrapper} $out/bin/qemu-system-x86_64
  '';
in
{
  virtualisation.vmVariant.virtualisation.qemu.package = qemuGl;
}
