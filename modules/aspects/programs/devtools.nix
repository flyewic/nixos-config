{ ... }:
{
  flake.modules.nixos.devtools = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      go
      rustup
      jdk
      bun
      cmake
      gh
      gopls
      jdt-language-server
    ];
  };
}
