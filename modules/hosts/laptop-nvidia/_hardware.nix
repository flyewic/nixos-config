{
  # TODO: replace with nixos-generate-config, or import a nixos-hardware profile.
  # This file is this machine only. Do not share it with modules/hosts/laptop.
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
