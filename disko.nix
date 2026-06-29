{
  # Single-disk BIOS (legacy boot) layout for a VMware guest.
  # VMware's default SCSI controller exposes the disk as /dev/sda.
  # GPT with a 1M BIOS-boot partition (EF02) where GRUB embeds its core.img;
  # no ESP because the firmware boots in legacy/CSM mode, not UEFI.
  disko.devices.disk.main = {
    device = "/dev/sda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02"; # BIOS boot partition (GRUB core.img embed)
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
