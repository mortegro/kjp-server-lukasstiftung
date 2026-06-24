{ config, lib, pkgs, modulesPath, ... }:
{
  # Filesystems and swap are declared by disko.nix — not here.
  # This file only carries the VMware-guest boot/kernel details.

  boot.initrd.availableKernelModules = [
    "ata_piix"      # IDE/SATA emulation
    "mptspi"        # LSI Logic Parallel SCSI (VMware default controller)
    "vmw_pvscsi"    # VMware Paravirtual SCSI (if selected)
    "nvme"          # NVMe controller (if selected)
    "uhci_hcd"
    "ehci_pci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
