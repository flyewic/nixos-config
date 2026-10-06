# nixos

NixOS configuration in the dendritic pattern. flake-parts is the top-level module system. import-tree loads every file under `modules/` as a flake-parts module. A file owns one feature and can contribute to both the `nixos` and `homeManager` classes.

Hosts import presets. Presets import aspects. A file existing does not enable a feature. home-manager is a NixOS module, so user config is part of the system generation.

Current presets are `common`, `dev`, `graphical`, `workstation`, `laptop`, `vm`, `server`, and `builder`. `workstation` includes NVIDIA, Steam, Gamemode, Faugus, Lutris, Heroic, ProtonPlus, Goverlay, and MangoHud. `laptop` does not. The `laptop-nvidia` host imports `laptop` and `nvidia-prime`. `vm` is `common`, `dev`, and `graphical` for a local QEMU box. `workstation`, `laptop`, and `vm` use oo7 for the secret portal. Hyprland, niri, and river are separate aspects. The host imports one.

Host modules are namespaced `<name>-host` (`desktop-host`, `laptop-host`, `laptop-nvidia-host`, `vm-host`) so a host never collides with a preset of the same name. One `machines` map in `modules/hosts.nix` feeds both `nixosConfigurations` and `colmenaHive`. Real hosts log in through greetd with the tuigreet greeter; the `vm` keeps ly autologin.

Disks are disko, LUKS2, stateful btrfs, declared per host. The ESP stays clear. Secrets are sops-nix with age. Remote deploy is colmena. Local switch after install is `nh os switch`.

Design notes are in `docs/nixos-dendritic-implementation.md`. Install order is in `docs/nixos-deploy.md`. `AGENTS.md` is the edit contract.

## Test VM

The `vm` host boots the shared aspects in QEMU/KVM without touching a real machine or reading any disk by-id. It is `common`, `dev`, and `graphical` plus the Hyprland aspect, and it is not a colmena target.

```bash
# Build the run script (no NixOS host required, just Nix + KVM).
nix build .#nixosConfigurations.vm.config.system.build.vm

# Boot it. `ly` auto-logs in flye into Hyprland.
./result/bin/run-nixos-vm-vm
# or: just run-vm
```

- Login: autologin as `flye`. That account's password is the sops hash. Root's password is `nixos`. Wheel sudo does not ask.
- Disk: `./nixos-vm.qcow2` persists between runs and is gitignored. Delete it to start clean.
- Throwaway disk: `NIX_DISK_IMAGE=/tmp/other.qcow2 ./result/bin/run-nixos-vm-vm`.
- Modifier: the shared Hyprland binds use the new Lua config (the 26.05 default) with a Lua `mod` local; the VM forces it to `ALT` so the host's Super bindings are not intercepted. The real hosts keep `SUPER`. Terminal is `Alt+Return` (kitty).

## Development

```bash
nix develop          # sops, age, ssh-to-age, colmena, nh, just, treefmt
just --list          # the recipes below mirror the AGENTS.md commands
nix flake check      # evaluates every host, then builds the checks
nix flake check --no-build   # evaluate only, build nothing
nix fmt
```

The `justfile` wraps the commands in `AGENTS.md` (`fmt`, `check`, `eval`, `switch`, `rebuild`, `deploy`, `deploy-dry`, `sops`, `rekey`) plus the VM (`build-vm`, `run-vm`). Run `just` with no recipe to list them.

`nix flake check` evaluates each `nixosConfigurations.*` toplevel (so a broken host fails the check) and builds the `checks.*` outputs, including `nixos-eval-*` and the treefmt check. It does not build the host systems.
