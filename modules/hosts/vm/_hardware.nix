{
  # QEMU/KVM guest. The disk image is built by `system.build.vm`, so this host
  # has no disko layout. Keep the virtio drivers in stage 1 for the VM image.
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    "9p"
    "9pnet_virtio"
  ];
  hardware.enableRedistributableFirmware = true;
  services.qemuGuest.enable = true;

  # The module system asserts a root filesystem and a boot loader even when a
  # config is only evaluated, which `nix flake check` does. The VM boots by
  # direct kernel boot from the image built by `system.build.vm`, so there is
  # no loader. The root matches the image's filesystem label.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub.enable = false;
}
