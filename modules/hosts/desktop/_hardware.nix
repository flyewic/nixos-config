{
  # TODO: replace with nixos-generate-config, or import a nixos-hardware profile.
  # virtio modules let the same file boot a QEMU VM before the generated file exists.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
  ];
  hardware.enableRedistributableFirmware = true;
}
