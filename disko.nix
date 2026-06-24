{
  # Single-disk UEFI layout for a VMware guest.
  # VMware's default SCSI controller exposes the disk as /dev/sda.
  # If you use NVMe change to /dev/nvme0n1; PVSCSI may also be /dev/sda.
  disko.devices.disk.main = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
