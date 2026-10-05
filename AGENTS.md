# AGENTS.md

NixOS configuration in the dendritic pattern. Read `docs/nixos-dendritic-implementation.md` for the design and `docs/nixos-deploy.md` for install order. This file is the contract. Do not re-litigate it.

## Decisions already made

- flake-parts is the only top-level module system. `flake.nix` is inputs plus `mkFlake` of `import-tree ./modules`.
- Every Nix file except `flake.nix` is a flake-parts module. One feature per file.
- Classes are `nixos` and `homeManager` only. No nix-darwin, no nixvim class.
- home-manager is a NixOS module. No standalone home-manager. No hjem.
- Presets import aspects. Hosts import presets. No `den`, no custom aspect graph.
- import-tree loads files. A file existing does not enable a feature. `_` prefix excludes a file.
- Disks are disko, stateful btrfs, private to the host. No impermanence.
- Secrets are sops-nix, age, one `secrets.yaml`. Not agenix, vaultix, or colmena `deployment.keys`.
- Deploy is colmena `colmenaHive`. Tags match preset names.
- Local switch after first boot is `nh os switch`. No `nh home`. Installer and rescue stay on `nixos-rebuild`.
- Channel is `nixos-unstable`. Inputs follow `nixpkgs`.
- Compositors are equal aspects: hyprland, niri, river. The host imports one. Not the preset.
- Gaming (NVIDIA, Steam, Gamemode, `/var/games`) is the workstation preset only.

## Layout

```text
modules/aspects/     one feature, both classes if it has both
modules/presets/     imports aspects, nothing else
modules/hosts/<name> identity, disk, hardware, deployment, preset list, compositor
modules/hosts.nix    only file that calls nixosSystem and makeHive
secrets/secrets.yaml encrypted
.sops.yaml           recipients
```

Import aspects and presets as `inputs.self.modules.<class>.<name>`. Never by path. Never from `config` inside `imports`.

## How to change it

New feature: add `modules/aspects/<name>.nix` with `flake.modules.nixos.<name>` and, if the user cares, `flake.modules.homeManager.<name>`. Then import it from a preset. Do not import it from a host unless it is host-private (disk, hardware, compositor).

New role: add a preset that imports existing presets or aspects. `workstation` already imports `common`, `dev`, `graphical`, `nvidia`, `steam`. `laptop` stops before nvidia and steam. `server` is `common` only.

New machine: `modules/hosts/<name>/{default.nix,disk.nix,hardware.nix}`, register it in `modules/hosts.nix` for both `nixosConfigurations` and `colmenaHive`, add an age recipient, `sops updatekeys`. Do not copy `desktop/disk.nix` onto a laptop or a server. The games subvolume is desktop-only.

Compositor swap: change the import on the host module, both the NixOS class and the home-manager user imports. Do not edit `graphical`.

## Do not

- Enable a feature by dropping a file in the tree.
- Put `deployment.*` only in colmena config. It lives on the host module. `deploymentOptions` must stay imported so `nixos-rebuild` still evaluates.
- Commit age private keys, or declare a secret before that host's key exists at `/var/lib/sops-nix/key.txt`.
- Bump `system.stateVersion` or `home.stateVersion`.
- Use `/dev/nvme*` or `/dev/sda` in disko. By-id only.
- Fill `TODO_USER`, hostnames, disk ids, or age keys with guesses.
- Add digga, flake-utils, haumea, deploy-rs, or agenix.
- Replace colmena with `nh`, or run `nh home`. Home-manager is the system generation.

## Commands

```bash
nix flake check
nix fmt
nh os switch -H desktop
nh os switch -H laptop
sudo nixos-rebuild switch --flake .#desktop   # installer and rescue only
colmena apply --on @desktop --dry-run
colmena apply --on @laptop
```

There is no `home-manager switch` and no `nh home`. User config is the system generation. `nh` is enabled by the `nh` aspect, imported from `common`.

## Commits

Write the subject as one imperative sentence, at most 72 characters. Say what landed. Write plain sentences, with no type prefix.

Add a body when the subject does not say why. Use it for a constraint the diff does not show. Wrap the body at 72 characters.

Keep one concern in each commit. Docs that cite each other belong in one commit. Commit a `flake.lock` bump on its own.

Run `nix fmt` before a commit that changes Nix. Commit the lockfile.

## Still open

Username, hostnames, disk by-ids, swap size, fish or nushell, which compositor the desktop imports first, tailnet name. Leave the markers. Ask.
