# import-tree ignores this file. disko runs it directly:
#   sudo nix run github:nix-community/disko -- --mode disko ./modules/hosts/laptop/_disk.nix
# No /games subvolume. Do not copy the desktop disk file.
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
              # TODO: swap subvolume, smaller than the desktop, sized to RAM.
              # disko only accepts a size like 16G, so the subvolume waits for that number.
            };
          };
        };
      };
    };
  };
}
