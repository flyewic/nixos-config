# import-tree ignores this file. disko runs it directly:
#   sudo nix run github:nix-community/disko -- --mode disko ./modules/hosts/desktop/_disk.nix
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/TODO_BY_ID"; # never /dev/nvme0n1
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
            # disko asks for this passphrase twice while formatting. The initrd
            # asks again at boot. It is not stored in the repo.
            settings.allowDiscards = true;
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" ];
                };
                "/games" = {
                  mountpoint = "/var/games";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
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
