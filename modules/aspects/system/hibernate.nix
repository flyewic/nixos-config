{ ... }:
{
  # The disk swapfile is the hibernation image. systemd ignores zram, reads
  # the btrfs offset itself, and stores it in the EFI HibernateLocation
  # variable. boot.resumeDevice stays empty: a resume= parameter without
  # that offset makes systemd refuse the file.
  flake.modules.nixos.hibernate =
    { config, ... }:
    {
      boot.initrd.systemd.enable = true;

      assertions = [
        {
          assertion = !config.security.protectKernelImage;
          message = "security.protectKernelImage adds nohibernate and disables hibernation.";
        }
      ];

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend-then-hibernate";
      };
    };
}
