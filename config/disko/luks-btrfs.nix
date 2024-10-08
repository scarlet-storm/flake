{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              label = "esp";
              content = {
                type = "filesystem";
                format = "vfat";
                extraArgs = [
                  "-n"
                  "ESP"
                ];
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
              };
            };
            luksroot = {
              size = "100%";
              type = "8304";
              label = "root-x86-64";
              content = {
                type = "luks";
                name = "root";
                extraFormatArgs = [
                  "--label"
                  "luksroot"
                  "--subsystem"
                  "nvme"
                ];
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-L"
                    "rootfs"
                  ];
                  subvolumes = {
                    "/nixos" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress-force=zstd"
                      ];
                    };
                    "/nixos/root" = { };
                    "/nixos/home" = { };
                    "/nixos/var" = { };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "10G";
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress-force=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
