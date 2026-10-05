# nixos

NixOS configuration in the dendritic pattern. flake-parts is the top-level module system. import-tree loads every file under `modules/` as a flake-parts module. A file owns one feature and can contribute to both the `nixos` and `homeManager` classes.

Hosts import presets. Presets import aspects. A file existing does not enable a feature. home-manager is a NixOS module, so user config is part of the system generation.

Current presets are `common`, `dev`, `graphical`, `workstation`, `laptop`, `server`, and `builder`. `workstation` includes NVIDIA, Steam, and Gamemode. `laptop` does not. Hyprland, niri, and river are separate aspects. The host imports one.

Disks are disko, stateful btrfs, declared per host. Secrets are sops-nix with age. Remote deploy is colmena. Local switch after install is `nh os switch`.

Design notes are in `docs/nixos-dendritic-implementation.md`. Install order is in `docs/nixos-deploy.md`. `AGENTS.md` is the edit contract.

