# Getting started and deploy

Companion to `nixos-dendritic-implementation.md`. That document says what the configuration is. This one is the order that actually boots a host.

Placeholders match the implementation guide. Do not invent disk ids, hostnames, or age keys. Fill them when the machine is in front of you.

Assumptions carried over: dendritic flake-parts config, home-manager as a NixOS module, disko with stateful btrfs, sops-nix with age, colmena, `nh` for local switches after the first boot. Desktop is the first host. Laptop is the second. Servers come later and skip the USB.

## What you need before the USB

- An existing Linux machine with Nix, or the NixOS installer itself if that is all you have.
- A USB stick with the NixOS minimal ISO for `x86_64-linux`. Graphical ISO is unnecessary.
- The repo cloned on the installer, or reachable over SSH from a machine that has it.
- Firmware and ethernet or a phone tether. Do not debug Wi-Fi from the installer.

You do not need colmena, nh, a tailnet, or a compositor for the first boot. The installer does not have `nh`.

## 1. Admin age key

Generate this on a machine you already trust, before the new host exists. This key rekeys secrets. It is not stored on the hosts.

```bash
nix shell nixpkgs#age --command age-keygen -o ~/age/admin.txt
nix shell nixpkgs#age --command age-keygen -y ~/age/admin.txt
```

Put the public key (`age1...`) in `.sops.yaml` as `admin_age`. Keep `admin.txt` off the repo and off the new machines. A password manager or a YubiKey-backed copy is the backup. There is no recovery if this key and every host key are lost.

## 2. Repo that evaluates

From the layout in the implementation guide, the first milestone is `nix flake check`, not a boot.

```bash
git init
nix flake lock
nix flake check
nix fmt
```

`modules/hosts.nix` may already name `desktop` and `laptop`. The laptop disk and hardware files can be empty stubs. `nix flake check` must pass with `TODO` hostnames still in place. It will not pass if an aspect references a secret file that does not exist. Add secrets after the first boot.

## 3. Installer

Write the minimal ISO and boot it. On the target:

```bash
sudo -i
ip -br addr
lsblk -o NAME,SIZE,MODEL,SERIAL
ls -l /dev/disk/by-id/
```

Copy the by-id path for the system disk into `modules/hosts/desktop/_disk.nix`. Never use `/dev/nvme0n1`. Names move. By-id does not.

Partition and mount with disko, then install:

```bash
sudo nix run github:nix-community/disko -- --mode disko ./modules/hosts/desktop/_disk.nix
sudo nixos-install --flake .#desktop
```

`nixos-install` sets the root password prompt. Set one. SSH with passwords stays off. After reboot, log in on the console as `TODO_USER` or as root, then:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

Stop here. No compositor, no Steam, no colmena. A TTY that rebuilds is the checkpoint. After `programs.nh` is on the system, later local switches use `nh os switch -H desktop`. Rescue and the installer stay on `nixos-rebuild`.

## 4. Host age key, then the first secret

sops-nix decrypts at activation. If a secret is declared and the key file is missing, `switch` fails. Install the key first.

On the desktop, as root:

```bash
mkdir -p /var/lib/sops-nix
age-keygen -o /var/lib/sops-nix/key.txt
chmod 0400 /var/lib/sops-nix/key.txt
age-keygen -y /var/lib/sops-nix/key.txt
```

Add that public key to `.sops.yaml` next to the admin key. From the admin machine, with `admin.txt` available:

```bash
cd /path/to/repo
sops secrets/secrets.yaml   # create it if needed
nix shell nixpkgs#sops --command sops updatekeys secrets/secrets.yaml
```

Commit the encrypted file and `.sops.yaml` only. Then declare one unimportant secret in `modules/aspects/sops.nix` and switch. Read it back from `/run/secrets`. If that works, real tokens can follow.

The key file is out of band. disko will destroy it on a reinstall. Repeat this step after any disko run. A later impermanence layout would need the key on a persistent volume. This config is stateful, so `/var/lib` survives a normal reboot.

## 5. Colmena, after one local switch

Colmena is not the installer. Point it at a host that already switched once.

On the admin machine, the SSH key that colmena uses must log in as `deployment.targetUser` (root in the guide). `deployment.targetHost` is an IP or a name that resolves from the admin machine. Tailscale can be that name later. It is not required for this step.

```bash
nix run .#colmena -- apply --on @desktop
```

If the flake does not expose a `colmena` package, run `nix run github:nix-community/colmena -- apply --on @desktop` from the repo. Dry-run first:

```bash
nix run github:nix-community/colmena -- apply --on @desktop --dry-run
```

A failed activation rolls back like `nixos-rebuild`. A failed copy means SSH or the target host string, not the NixOS config.

## 6. Laptop

Same sequence, other files.

1. New host age key on the laptop, public half into `.sops.yaml`, `sops updatekeys`.
2. By-id into `modules/hosts/laptop/_disk.nix`. No `/games` subvolume. Smaller swap.
3. Host module imports the `laptop` preset, not `workstation`. No NVIDIA, no Steam.
4. disko, `nixos-install --flake .#laptop`, console login, local switch.
5. Secret decrypt check.
6. `colmena apply --on @laptop`.

Do not copy `desktop/_disk.nix` and edit the device path. The games subvolume will be created on the laptop disk.

## 7. A later server

No USB if the machine already runs NixOS and accepts SSH.

1. Generate its age key, add the recipient, rekey.
2. Add `modules/hosts/<name>/` importing the `server` preset.
3. Register it in `modules/hosts.nix` for both `nixosConfigurations` and `colmenaHive`.
4. `colmena apply --on @server` from the admin machine.

A builder is the same with the `builder` preset. Do not set up remote builders until that host has switched.

## Day to day

| Change | Command |
| --- | --- |
| Local edit on the machine you are sitting at | `nh os switch -H desktop` |
| Same, laptop | `nh os switch -H laptop` |
| Installer, rescue, or nh not installed yet | `sudo nixos-rebuild switch --flake .#desktop` |
| Push to a host you are not sitting at | `colmena apply --on @desktop` or `@laptop` |
| Update inputs | `nix flake update`, then switch, then commit `flake.lock` |
| Format | `nix fmt` |

User config ships with the system generation. There is no `home-manager switch` and no `nh home`. A compositor change is swapping the import on the host and switching. It is not a preset edit. `nh` does not replace colmena.

## When a switch fails

- Secret declared, key missing: activation error from sops-nix. Install the key, or drop the secret, and switch again.
- `deployment` option unknown: `deploymentOptions` is not imported into `nixosSystem`. See the host wiring in the implementation guide.
- Disk device missing at boot: by-id typo, or the disk moved. Fix `_disk.nix` from the installer. Do not rerun disko on a disk that already has the install unless you mean to wipe it.
- Colmena cannot connect: target host and root SSH, not the flake. `--dry-run` still evaluates. A successful dry-run with a failed apply is the network.

## Still not filled in

Username, hostnames, disk by-ids, swap size, shell, first compositor, tailnet name. None of those block section 3 except the desktop by-id, which you read off the installer.
