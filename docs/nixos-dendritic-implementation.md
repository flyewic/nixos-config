# Dendritic NixOS implementation guide

Status: design locked, not yet a repository. Placeholders are marked `TODO`.

This guide builds a new NixOS configuration in the dendritic pattern. Every Nix file except `flake.nix` is a flake-parts module. A file owns one feature and contributes to every class that feature touches. Hosts do not copy features. They import presets. Presets import aspects.

## Locked decisions

| Topic | Choice |
| --- | --- |
| Pattern | Dendritic (mightyiam): top-level flake-parts modules, one feature per file |
| Loader | `vic/import-tree`. Files prefixed `_` are not imported |
| Classes | `nixos` and `homeManager` only |
| User config | home-manager as a NixOS module, same generation as the system |
| Composition | Preset modules import aspects. Hosts import presets. No `den` |
| Hosts now | Gaming and dev desktop, development laptop |
| Hosts later | Servers and builders, added as presets, not a refactor |
| Disks | disko, stateful btrfs subvolumes, layout private to the host |
| Secrets | sops-nix, age, one `secrets.yaml` |
| Deploy | colmena `colmenaHive`, tags matching presets |
| Local switch | `nh os switch`. Installer and rescue stay on `nixos-rebuild` |
| Channel | `nixos-unstable`, every input follows `nixpkgs`, pin with `flake.lock` |
| Session | Hyprland, niri, and river sketched as equal aspects. Host imports one |
| Gaming | Desktop only: NVIDIA, Steam, Gamemode, a games subvolume |

Out of scope for v1: nix-darwin, nixvim as its own class, impermanence, agenix, vaultix, deploy-rs, standalone home-manager, `nh home`.

## Why this shape

import-tree loads files. It must not enable features. A server that appears later should not grow a Steam closure because a file exists.

home-manager is the user layer because the laptop is a dev machine. The catalogue (`programs.git`, shell, editor, session variables) is the point. Compositor aspects may still drop to `xdg.configFile` when a `programs.*` module gets in the way. hjem was rejected as the default: it only links files, so the laptop would reimplement the catalogue. It remains a valid escape hatch for a single file, not a second activation model.

Presets are ordinary modules. Inheritance is `imports`. Overrides are `lib.mkForce` and `lib.mkDefault`. A custom aspect graph would duplicate the module system.

`nh` is the local switch command after the first boot. It reimplements `nixos-rebuild` with a build tree, a diff, and a confirmation. It is not a deploy tool, and `nh home` is unused because home-manager is already in the system generation. The installer ISO does not have it, so install and rescue stay on `nixos-rebuild`.

## Repository layout

```text
flake.nix
flake.lock
.sops.yaml
secrets/
  secrets.yaml
modules/
  flake-parts.nix          # imports flake-parts.flakeModules.modules
  treefmt.nix
  hosts.nix                # nixosConfigurations and colmenaHive
  hosts/
    desktop/
      default.nix          # identity, deployment, preset imports, HM user
      disk.nix             # disko, including games subvolume
      hardware.nix         # generated, or nixos-hardware import
    laptop/
      default.nix
      disk.nix
      hardware.nix
  presets/
    common.nix             # nix, locale, users, openssh, sops, nh
    dev.nix                # shells, git, editor, build tools
    graphical.nix          # seat, pipewire, portal, fonts
    workstation.nix        # common + dev + graphical + gaming
    laptop.nix             # common + dev + graphical + power
    server.nix             # common only, stub for later
    builder.nix            # common + dev + remote build stub
  aspects/
    nix.nix
    users.nix
    openssh.nix
    nh.nix
    sops.nix
    pipewire.nix
    nvidia.nix
    steam.nix
    hyprland.nix
    niri.nix
    river.nix
    tailscale.nix          # stub, enable per host
```

Naming: aspect and preset names are the same in both classes when both exist. `modules/presets/dev.nix` defines `flake.modules.nixos.dev` and `flake.modules.homeManager.dev`.

## Implementation order

Do not start with the compositor. A host that evaluates is the first milestone.

1. Flake skeleton, empty host, `nix flake check`.
2. `common` preset: nix, user, locale, openssh, nh.
3. disko layouts and a bootable desktop in a VM or on metal.
4. home-manager wired through the host, `dev` preset.
5. `graphical` plus the three compositor aspects. Import one.
6. NVIDIA, Steam, Gamemode on the desktop only.
7. sops, then colmena.
8. Laptop host by copying the desktop host module and swapping presets and disk.

## Phase 1: flake skeleton

`flake.nix` declares inputs and nothing else.

```nix
{
  description = "Dendritic NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    colmena = {
      url = "github:nix-community/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}
```

`modules/flake-parts.nix` turns on the modules option. Without this, `flake.modules` is not defined.

```nix
{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
```

`modules/treefmt.nix` is the formatter. `nix fmt` should work before the first host does.

```nix
{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  perSystem = { pkgs, ... }: {
    treefmt.programs.nixfmt.enable = true;
  };
}
```

## Phase 2: aspects

An aspect file is a flake-parts module. It writes deferred modules into `flake.modules.<class>.<name>`. It does not call `nixosSystem`.

```nix
# modules/aspects/nix.nix
{ inputs, ... }:
{
  flake.modules.nixos.nix = { pkgs, ... }: {
    nixpkgs.hostPlatform = "x86_64-linux";
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    system.stateVersion = "26.05"; # TODO: set to the release installed, then never bump
  };
}
```

`stateVersion` is per host in practice. Set it in the host module, not in the shared aspect, if the two machines are installed on different dates.

Users are a shared aspect. The username is one constant, defined once.

```nix
# modules/aspects/users.nix
{ ... }:
let
  user = "TODO_USER";
in
{
  flake.modules.nixos.users = { pkgs, ... }: {
    users.users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.fish; # or pkgs.nushell; pick in the dev preset if it should vary
    };
    security.sudo.wheelNeedsPassword = true;
  };

  flake.modules.homeManager.users = {
    home.username = user;
    home.homeDirectory = "/home/${user}";
    home.stateVersion = "26.05";
  };
}
```

OpenSSH is the same feature on both classes: the system runs the daemon, the user holds the client config.

```nix
# modules/aspects/openssh.nix
{ ... }:
{
  flake.modules.nixos.openssh = {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };

  flake.modules.homeManager.openssh = {
    programs.ssh.enable = true;
  };
}
```

`nh` is a common aspect. The flake path is the checkout on that machine, so the host module may override it. Servers get the package. They do not have to set `flake` if nobody sits there.

```nix
# modules/aspects/nh.nix
{ ... }:
{
  flake.modules.nixos.nh = {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 3";
      flake = "/home/TODO_USER/src/nixos"; # TODO: real checkout, or override per host
    };
  };
}
```

`programs.nh.clean` overlaps `nix.gc` in the nix aspect. Keep one. The guide keeps `nh` clean and leaves `nix.gc` as the fallback if `nh` is later dropped.

## Phase 3: presets

A preset imports aspects by the flake output `inputs.self.modules.<class>.<name>`, not by path. Paths defeat the pattern: moving a file would break the import. `self.modules` is populated by flake-parts from `flake.modules`.

Do not use `config.flake.modules` inside an `imports` list. `imports` cannot depend on `config`. The flake output is the supported reference.

```nix
# modules/presets/common.nix
{ inputs, ... }:
{
  flake.modules.nixos.common = {
    imports = with inputs.self.modules.nixos; [ nix users openssh sops nh ];
  };
  flake.modules.homeManager.common = {
    imports = with inputs.self.modules.homeManager; [ users openssh ];
  };
}
```

```nix
# modules/presets/dev.nix
{ inputs, ... }:
{
  flake.modules.nixos.dev = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ git ];
  };

  flake.modules.homeManager.dev = { pkgs, ... }: {
    programs.git.enable = true;
    programs.fish.enable = true; # TODO: fish or nushell
  };
}
```

```nix
# modules/presets/graphical.nix
{ inputs, ... }:
{
  flake.modules.nixos.graphical = {
    imports = with inputs.self.modules.nixos; [ pipewire ];
    services.xserver.enable = false;
  };
  flake.modules.homeManager.graphical = {
    # fonts, cursor, gtk theme live here once a compositor is chosen
  };
}
```

```nix
# modules/presets/workstation.nix
{ inputs, ... }:
{
  flake.modules.nixos.workstation = {
    imports = with inputs.self.modules.nixos; [
      common dev graphical nvidia steam
    ];
  };
  flake.modules.homeManager.workstation = {
    imports = with inputs.self.modules.homeManager; [
      common dev graphical
    ];
  };
}
```

```nix
# modules/presets/laptop.nix
{ inputs, ... }:
{
  flake.modules.nixos.laptop = {
    imports = with inputs.self.modules.nixos; [
      common dev graphical
    ];
    services.power-profiles-daemon.enable = true;
    # TODO: tlp vs power-profiles-daemon, wireless backend
  };
  flake.modules.homeManager.laptop = {
    imports = with inputs.self.modules.homeManager; [
      common dev graphical
    ];
  };
}
```

`server.nix` and `builder.nix` exist as stubs so the next machine is an import. `server` is `common` only. `builder` is `common` plus `dev` plus `nix.settings.trusted-users`.

Inheritance rule: a more specific preset imports the broader one. `workstation` imports `common`. A host imports `workstation`, not `common` and `workstation`. Overriding a preset is a host module applied after the preset, using `mkForce`.

## Phase 4: hosts

`modules/hosts.nix` is the only file that calls `nixosSystem` and `makeHive`.

```nix
# modules/hosts.nix
{ inputs, self, ... }:
let
  inherit (inputs.nixpkgs) lib;
  user = "TODO_USER";

  mkNixos = name: modules:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.colmena.nixosModules.deploymentOptions
        inputs.home-manager.nixosModules.home-manager
        { networking.hostName = name; }
      ] ++ modules;
    };
in
{
  flake.nixosConfigurations = {
    desktop = mkNixos "desktop" [ self.modules.nixos.desktop ];
    laptop = mkNixos "laptop" [ self.modules.nixos.laptop ];
  };

  flake.colmenaHive = inputs.colmena.lib.makeHive {
    meta.nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
    desktop = self.modules.nixos.desktop;
    laptop = self.modules.nixos.laptop;
  };
}
```

Importing `deploymentOptions` into `nixosSystem` keeps `deployment.*` from failing evaluation outside colmena. Colmena reads the same options when it evaluates the hive.

The desktop host is identity, disk, hardware, deployment, and a preset list. The compositor is a host choice, not part of `workstation`, so swapping it does not fork the preset.

```nix
# modules/hosts/desktop/default.nix
{ inputs, ... }:
let
  user = "TODO_USER";
in
{
  flake.modules.nixos.desktop = { ... }: {
    imports = [
      ./disk.nix
      ./hardware.nix
      inputs.disko.nixosModules.disko
      inputs.self.modules.nixos.workstation
      inputs.self.modules.nixos.hyprland # TODO: hyprland | niri | river
    ];

    deployment = {
      targetHost = "TODO_DESKTOP_HOST"; # tailscale name or IP
      targetUser = "root";
      tags = [ "workstation" "desktop" ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${user}.imports = [
        inputs.self.modules.homeManager.workstation
        inputs.self.modules.homeManager.hyprland
      ];
    };
  };
}
```

The laptop host is the same file with `laptop` presets, no `nvidia` or `steam`, and its own compositor import. Hardware modules come from `nixos-hardware` when a profile exists, otherwise from `nixos-generate-config`.

## Phase 5: disks

Stateful btrfs. No impermanence, no tmpfs root. Subvolumes exist so `/nix` and `/home` can be snapshotted independently of root.

Desktop adds a games subvolume. Steam libraries should live there, not under `/home`, so a home rollback does not touch game data.

```nix
# modules/hosts/desktop/disk.nix
{
  disko.devices.disk.main = {
    type = "disk";
    device = "TODO_BY_ID"; # /dev/disk/by-id/..., never /dev/nvme0n1
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "/root" = {
                mountpoint = "/";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "/nix" = {
                mountpoint = "/nix";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "/home" = {
                mountpoint = "/home";
                mountOptions = [ "compress=zstd" ];
              };
              "/games" = {
                mountpoint = "/var/games";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "/swap" = {
                mountpoint = "/swap";
                swap.swapfile.size = "32G"; # TODO: match RAM
              };
            };
          };
        };
      };
    };
  };
}
```

Laptop disk is the same without `/games`, and with a smaller swap. Do not factor the whole disko attrset into a shared aspect. A helper for mount options is enough.

Install with disko, then the flake:

```bash
sudo nix run github:nix-community/disko -- --mode disko ./modules/hosts/desktop/disk.nix
sudo nixos-install --flake .#desktop
```

## Phase 6: compositors

Three aspects, same shape, host imports one. NixOS side enables the program and a display manager or a TTY login. home-manager side holds the user config.

Do not put the compositor in `graphical`. `graphical` is seat, PipeWire, portals, fonts.

Hyprland:

```nix
# modules/aspects/hyprland.nix
{ ... }:
{
  flake.modules.nixos.hyprland = { pkgs, ... }: {
    programs.hyprland.enable = true;
    security.pam.services.hyprlock = {};
  };

  flake.modules.homeManager.hyprland = { ... }: {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # TODO: monitors, binds, nvidia env
      };
    };
  };
}
```

Niri:

```nix
# modules/aspects/niri.nix
{ ... }:
{
  flake.modules.nixos.niri = {
    programs.niri.enable = true;
  };
  flake.modules.homeManager.niri = {
    programs.niri = {
      enable = true;
      settings = {
        # TODO
      };
    };
  };
}
```

River has no equivalent `programs.river` module that covers config. Keep it as files so the three aspects stay comparable.

```nix
# modules/aspects/river.nix
{ ... }:
{
  flake.modules.nixos.river = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.river ];
  };
  flake.modules.homeManager.river = {
    xdg.configFile."river/init".source = ./river/init;
  };
}
```

NVIDIA note, desktop only: Hyprland needs the usual env (`WLR_NO_HARDWARE_CURSORS` or the current equivalent, `LIBVA_DRIVER_NAME=nvidia`). Put that in the hyprland aspect behind `config.hardware.nvidia.enabled` or a host tag, not in the laptop import. Niri and river get the same env block in their own aspect. Do not share it through `graphical`, or the laptop inherits NVIDIA variables.

## Phase 7: gaming

Desktop preset only. Open kernel module, modesetting, Steam, Gamemode. No per-title fixes in v1.

```nix
# modules/aspects/nvidia.nix
{ ... }:
{
  flake.modules.nixos.nvidia = { config, pkgs, ... }: {
    hardware.graphics.enable = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia = {
      open = true;
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };
}
```

```nix
# modules/aspects/steam.nix
{ ... }:
{
  flake.modules.nixos.steam = { pkgs, ... }: {
    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    # Library path is /var/games from the desktop disko layout.
  };
}
```

Confirm the running driver after the first boot with `nvidia-smi`. If the open module misbehaves on that GPU generation, flip `hardware.nvidia.open` in this aspect only.

## Phase 8: secrets

One file, age recipients per host. sops-nix is imported from the `sops` aspect, which `common` already pulls in, so every host can decrypt. Hosts only add their key path.

```yaml
# .sops.yaml
keys:
  - &admin_age age1TODO
creation_rules:
  - path_regex: secrets/.*\.yaml
    key_groups:
      - age:
          - *admin_age
          - age1TODO_DESKTOP
          - age1TODO_LAPTOP
```

```nix
# modules/aspects/sops.nix
{ ... }:
{
  flake.modules.nixos.sops = { ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ]; # see note
    sops.defaultSopsFile = ../../secrets/secrets.yaml;
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  };
}
```

`inputs` has to be a module argument. Write `{ inputs, ... }:`. The key file is installed out of band on first boot (`sops-nix` documents the age key path). Do not commit keys.

User-level secrets go through `sops-nix` home-manager module only when a secret is actually needed in `$HOME`. Until then, skip that class.

## Phase 9: colmena

Apply by tag, which matches presets:

```bash
colmena apply --on @desktop
colmena apply --on @workstation
colmena apply --on @laptop
```

A future server is a host module with `tags = [ "server" ];` and `imports = [ self.modules.nixos.server ];`, plus one line in `hosts.nix`. No preset changes required unless the server needs a service aspect.

Build on the workstation and push. For a builder host later, set `deployment.buildOnTarget = false` and a remote builder in the `builder` preset. Do not design remote builders until that machine exists.

## Adding a machine

1. `modules/hosts/<name>/{default.nix,disk.nix,hardware.nix}`.
2. Import an existing preset. Add a preset only if the role is new.
3. Register the host in `modules/hosts.nix` for both `nixosConfigurations` and `colmenaHive`.
4. Add the age recipient to `.sops.yaml` and rekey.
5. Set `deployment.targetHost` and tags.

## Conventions

- One feature per file. A file that configures Steam and NVIDIA is two aspects.
- Both classes of a feature live in that file.
- Presets import aspects. Aspects do not import presets.
- Hosts import presets and at most the hardware, disk, and compositor exceptions.
- No `specialArgs` for feature flags. Flags are imports.
- `_` prefix on files that import-tree must ignore (generated hardware notes, local overrides).
- `nix fmt` before commit. Lockfile is committed.

## Open items before the repo exists

- Username, desktop hostname, laptop hostname.
- Disk by-id for both machines, swap size, whether the desktop games subvolume is a separate disk.
- Shell: fish or nushell. The `dev` preset is the only place this should be set.
- Age key locations and who the admin recipient is.
- Which compositor the desktop imports first. The other two aspects still land in the tree.
- Wireless and power on the laptop (NetworkManager is a safe `common` default; power stays in the laptop preset).
- Tailscale: stub aspect now, enable per host when the tailnet name is the colmena target.
- `stateVersion` set to the release actually installed, then left alone.
