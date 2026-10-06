# Dendritic NixOS implementation guide

Status: implemented. `AGENTS.md` is the edit contract; this guide records the design and the reasoning behind it. Placeholders are marked `TODO`.

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
| Disks | disko, LUKS2, stateful btrfs subvolumes, layout private to the host. The ESP stays clear |
| Secrets | sops-nix, age, one `secrets.yaml` |
| Deploy | colmena `colmenaHive`, tags matching presets |
| Local switch | `nh os switch`. Installer and rescue stay on `nixos-rebuild` |
| Channel | `nixos-unstable`, every input follows `nixpkgs`, pin with `flake.lock`. Kernel is `linuxPackages_latest` from that pin |
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
  checks.nix               # perSystem nixos-eval checks
  devshell.nix             # admin devShell
  hosts.nix                # machines map -> nixosConfigurations and colmenaHive
  hosts/
    desktop/
      default.nix          # identity, deployment, preset imports, HM user
      _disk.nix            # disko, including games subvolume. _ skips import-tree
      _hardware.nix        # generated, or nixos-hardware import
    laptop/
      default.nix
      _disk.nix
      _hardware.nix
    laptop-nvidia/
      default.nix          # hybrid: laptop preset + nvidia-prime
      _disk.nix
      _hardware.nix
    vm/
      default.nix          # QEMU test box, not a colmena target
      _qemu.nix            # wrapped qemu with the Nix Mesa for virgl
      _hardware.nix
  presets/
    common.nix             # nix, locale, users, openssh, sops, nh
    dev.nix                # shells, git, editor, terminals, build tools
    graphical.nix          # seat, pipewire, portal, fonts, flatpak
    workstation.nix        # common + dev + graphical + gaming
    laptop.nix             # common + dev + graphical + power
    vm.nix                 # common + dev + graphical + oo7
    server.nix             # common only, stub for later
    builder.nix            # common + dev + remote build stub
  aspects/
    system/                users, locale, keyboard, nix, kernel, network, openssh, sops, nh, tailscale
    programs/              fish, alacritty, ghostty, kitty, terminal-session, zellij, herdr, fuzzel
    programs/editors/      neovim, zed
    programs/tools/        fastfetch, btop
    session/               hyprland, niri, river, greetd, pipewire, gnome-keyring, oo7
    hardware/              nvidia, nvidia-prime
    gaming/                steam, faugus, lutris, heroic, protonplus, goverlay, mangohud
    flatpak/               default (daemon), bitwarden, spotify, goofcord, signal, zen, easyeffects
```

Naming: aspect and preset names are the same in both classes when both exist. `modules/presets/dev.nix` defines `flake.modules.nixos.dev` and `flake.modules.homeManager.dev`. Host modules are namespaced `<name>-host` (`desktop-host`, `laptop-host`, `laptop-nvidia-host`, `vm-host`), so a host name can never collide with a preset of the same name.

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
# modules/aspects/system/nix.nix
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
  };
}
```

`stateVersion` is the flake-parts option in `modules/aspects/system/users.nix`. Hosts and home-manager read `config.stateVersion`. A machine installed on a later release sets `system.stateVersion` itself.

Users are a shared aspect. The username is the flake-parts option `username` in that file. Other modules read `config.username`. Do not copy the string into a host.

```nix
# modules/aspects/system/users.nix
{ config, lib, ... }:
{
  options.username = lib.mkOption {
    type = lib.types.str;
    default = "flye";
  };

  options.stateVersion = lib.mkOption {
    type = lib.types.str;
    default = "26.05";
  };

  config = {
    flake.modules.nixos.users = { pkgs, ... }: {
      users.users.${config.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        shell = pkgs.fish; # or pkgs.nushell; pick in the dev preset if it should vary
      };
      security.sudo.wheelNeedsPassword = true;
    };

    flake.modules.homeManager.users = {
      home.username = config.username;
      home.homeDirectory = "/home/${config.username}";
      home.stateVersion = config.stateVersion;
    };
  };
}
```

OpenSSH is the same feature on both classes: the system runs the daemon, the user holds the client config.

```nix
# modules/aspects/system/openssh.nix
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
# modules/aspects/system/nh.nix
{ config, ... }:
{
  flake.modules.nixos.nh = {
    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 14d --keep 3";
      flake = "/home/${config.username}/src/nixos"; # TODO: real checkout, or override per host
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
    imports = with inputs.self.modules.nixos; [ fish ];
    environment.systemPackages = with pkgs; [ git ];
    users.defaultUserShell = pkgs.fish;
  };

  flake.modules.homeManager.dev = {
    imports = with inputs.self.modules.homeManager; [ fish ];
    programs.git.enable = true;
  };
}
```

```nix
# modules/presets/graphical.nix
{ inputs, ... }:
{
  flake.modules.nixos.graphical = {
    imports = with inputs.self.modules.nixos; [
      pipewire flatpak bitwarden spotify goofcord signal zen
    ];
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
      common dev graphical nvidia steam faugus lutris heroic protonplus goverlay mangohud
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
{ inputs, self, config, ... }:
let
  lib = inputs.nixpkgs.lib;

  # Wiring every host shares.
  hostBase = {
    imports = [
      inputs.disko.nixosModules.disko
      inputs.colmena.nixosModules.deploymentOptions
      inputs.home-manager.nixosModules.home-manager
    ];
    system.stateVersion = config.stateVersion;
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };

  mkNixos = modules: lib.nixosSystem { modules = [ hostBase ] ++ modules; };

  # One entry per machine. Both outputs derive from this map.
  machines = {
    desktop = {
      deployable = true;
      modules = [ self.modules.nixos."desktop-host" ];
    };
    laptop = {
      deployable = true;
      modules = [ self.modules.nixos."laptop-host" ];
    };
    "laptop-nvidia" = {
      deployable = true;
      modules = [ self.modules.nixos."laptop-nvidia-host" ];
    };
    vm = {
      deployable = false;
      modules = [ self.modules.nixos."vm-host" ];
    };
  };

  asNode = m: { imports = [ hostBase ] ++ m.modules; };
in
{
  flake.nixosConfigurations = lib.mapAttrs (_: m: mkNixos m.modules) machines;

  flake.colmenaHive = inputs.colmena.lib.makeHive (
    { meta.nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; }; }
    // lib.mapAttrs (_: asNode) (lib.filterAttrs (_: m: m.deployable) machines)
  );
}
```

`hostBase` carries `deploymentOptions`, which keeps `deployment.*` from failing evaluation outside colmena; colmena gets the same base through `asNode`. One `machines` map feeds both `nixosConfigurations` and `colmenaHive`, so a new machine is one entry, not two lists that can drift.

The desktop host is identity, disk, hardware, deployment, and a preset list. The compositor is a host choice, not part of `workstation`, so swapping it does not fork the preset. A single `compositor` binding feeds both classes.

```nix
# modules/hosts/desktop/default.nix
{ inputs, config, ... }:
let
  user = config.username;
  compositor = "hyprland"; # hyprland | niri | river
in
{
  flake.modules.nixos."desktop-host" = {
    imports = [
      ./_disk.nix
      ./_hardware.nix
      inputs.self.modules.nixos.workstation
      inputs.self.modules.nixos.${compositor}
    ];

    networking.hostName = "bropor";
    time.timeZone = "Europe/Stockholm";

    deployment = {
      targetHost = "TODO_DESKTOP_HOST"; # tailscale name or IP
      targetUser = "root";
      tags = [ "workstation" "desktop" ];
    };

    home-manager.users.${user}.imports = [
      inputs.self.modules.homeManager.workstation
      inputs.self.modules.homeManager.${compositor}
    ];
  };
}
```

Every host module is namespaced `<name>-host`, so a preset and a host may share a role name. The `laptop` preset writes `flake.modules.nixos.laptop`; the plain laptop writes `flake.modules.nixos."laptop-host"` (disk, hardware, compositor, deployment) and imports the preset itself. `hosts.nix` builds both `nixosConfigurations.laptop` and the colmena node from the one `machines` entry. Hardware modules come from `nixos-hardware` when a profile exists, otherwise from `nixos-generate-config`.

`laptop-nvidia` imports `inputs.self.modules.nixos.laptop` and `inputs.self.modules.nixos."nvidia-prime"`. It does not import `laptop-host`. PRIME bus IDs stay on that host. Offload turns on when `nvidiaBusId` and one of `intelBusId` or `amdgpuBusId` are set. Do not add `nvidia-prime` to the `laptop` preset.

## Phase 5: disks

Stateful btrfs on LUKS2. No impermanence, no tmpfs root. Subvolumes exist so `/nix` and `/home` can be snapshotted independently of root. The ESP stays unencrypted so the bootloader can read the kernel. The passphrase is typed while disko formats the disk, and the initrd asks for it again at every boot. It is not stored in the repo. The desktop swapfile sits inside the encrypted volume. Resume-from-hibernate is not set up.

The test VM has no disko file and no LUKS. Its disk is the QEMU image.

Desktop adds a games subvolume. Steam libraries should live there, not under `/home`, so a home rollback does not touch game data.

```nix
# modules/hosts/desktop/_disk.nix
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-TS1TMTE220S_G023930316"; # never /dev/nvme0n1. disko requires an absolute path
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
            type = "luks";
            name = "cryptroot";
            # No passwordFile and no settings.keyFile: disko asks twice while
            # formatting. The initrd asks again at boot.
            settings.allowDiscards = true;
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
  };
}
```

Laptop disk is the same LUKS2 wrap without `/games`, and with a smaller swap. Each host chooses its own passphrase when that disk is formatted. Do not factor the whole disko attrset into a shared aspect. A helper for mount options is enough.

Install with disko, then the flake:

```bash
sudo nix run github:nix-community/disko -- --mode disko ./modules/hosts/desktop/_disk.nix
sudo nixos-install --flake .#desktop
```

## Phase 6: compositors

Three aspects, same shape, host imports one. NixOS side enables the program and a display manager or a TTY login. home-manager side holds the user config.

Do not put the compositor in `graphical`. `graphical` is seat, PipeWire, portals, fonts, the Flatpak daemon, and the Flatpak apps every graphical host gets. An app only some of those hosts need is imported by that preset. `easyeffects` is on `workstation`.

Hyprland:

```nix
# modules/aspects/session/hyprland.nix
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
# modules/aspects/session/niri.nix
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
# modules/aspects/session/river.nix
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

Desktop preset only. Open kernel module, modesetting, Steam, Gamemode, Faugus, Lutris, Heroic, ProtonPlus, Goverlay, and MangoHud. No per-title fixes in v1.

```nix
# modules/aspects/hardware/nvidia.nix
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
# modules/aspects/gaming/steam.nix
{ ... }:
{
  flake.modules.nixos.steam = {
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
# modules/aspects/system/sops.nix
{ ... }:
{
  flake.modules.nixos.sops = { ... }: {
    imports = [ inputs.sops-nix.nixosModules.sops ]; # see note
    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
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

A future server is a host module with `tags = [ "server" ];` and `imports = [ self.modules.nixos.server ];`, plus one entry in the `machines` map in `hosts.nix`. No preset changes required unless the server needs a service aspect.

Build on the workstation and push. For a builder host later, set `deployment.buildOnTarget = false` and a remote builder in the `builder` preset. Do not design remote builders until that machine exists.

## Adding a machine

1. `modules/hosts/<name>/{default.nix,_disk.nix,_hardware.nix}` defining `flake.modules.nixos."<name>-host"`. The `_` prefix keeps import-tree from loading the disk and hardware files. disko runs `_disk.nix` directly.
2. Import an existing preset. Add a preset only if the role is new.
3. Add one entry to the `machines` map in `modules/hosts.nix` (`deployable = false` if colmena must not target it). It feeds both `nixosConfigurations` and `colmenaHive`.
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

## Open items

- Laptop hostname. Desktop hostname is `bropor`.
- Laptop disk by-id and swap size. Desktop disk by-id and swap size are set.
- Shell: fish. The `dev` preset sets `users.defaultUserShell`. The fish aspect holds the config.
- Age key locations and who the admin recipient is.
- Which compositor the desktop imports first. The other two aspects still land in the tree.
- Wireless and power on the laptop (NetworkManager is a safe `common` default; power stays in the laptop preset).
- Tailscale: stub aspect now, enable per host when the tailnet name is the colmena target.
- `stateVersion` stays on the shared default unless a host was installed on another release.
