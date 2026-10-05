# List recipes
default:
    @just --list

# Format the tree with treefmt
fmt:
    nix fmt

# Evaluate every host and build the flake checks
check:
    nix flake check

# Evaluate only, build nothing
eval:
    nix flake check --no-build

# Build the QEMU test VM runner
build-vm:
    nix build .#nixosConfigurations.vm.config.system.build.vm

# Build and boot the QEMU test VM
run-vm: build-vm
    ./result/bin/run-nixos-vm-vm

# nh os switch on the machine you are sitting at
switch host="desktop":
    nh os switch -H {{ host }}

# Installer and rescue only: nixos-rebuild on the target
rebuild host="desktop":
    sudo nixos-rebuild switch --flake .#{{ host }}

# Colmena dry run for a host or preset tag
deploy-dry target="desktop":
    colmena apply --on @{{ target }} --dry-run

# Colmena apply for a host or preset tag
deploy target="desktop":
    colmena apply --on @{{ target }}

# Edit the encrypted secrets file
sops:
    SOPS_AGE_KEY_FILE="$HOME/age/admin.txt" sops secrets/secrets.yaml

# Rekey secrets to the current .sops.yaml recipients
rekey:
    SOPS_AGE_KEY_FILE="$HOME/age/admin.txt" sops updatekeys secrets/secrets.yaml
