# ============================================================================
# PLACEHOLDER - REGENERATE THIS ON THE LAPTOP BEFORE INSTALLING.
#
# The UUIDs below are fake and WILL NOT BOOT. To generate the real thing: boot
# the NixOS installer on the Precision 3490, partition and mount, then
#     nixos-generate-config --root /mnt
# and copy /mnt/etc/nixos/hardware-configuration.nix over this file.
#
# BIOS: Dell ships these with SATA Operation = "RAID On" (Intel RST), which
# hides the NVMe from the Linux installer. Switch it to AHCI/NVMe first - and do
# it BEFORE removing Windows, or Windows will BSOD on the next boot.
#
# BEFORE REPARTITIONING: confirm BitLocker status on C: and save the recovery
# key. I could not read it (the query needs admin). Same for Secure Boot - if it
# is on, either disable it in BIOS or sign with lanzaboote (sbctl is packaged).
# ============================================================================
{ config, lib, pkgs, modulesPath, ... }:
{
  # Pulls in hardware.enableRedistributableFirmware = mkDefault true, which the
  # old WSL-generated profile was missing. laptop.nix also sets it explicitly.
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  warnings = [
    "hosts/SHELL/hardware-configuration.nix is still the placeholder - regenerate it with nixos-generate-config before installing."
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "vmd" # drop this once SATA Operation is AHCI/NVMe rather than RAID On
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ]; # i915 comes from the nixos-hardware profile
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "ext4";
  };

  # The NEW ~1 GB ESP, not the factory 100 MB one that Windows uses.
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0000-0000";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # 63.5 GiB RAM, and laptop.nix enables zramSwap. Add a >= 64 GiB swap
  # partition here only if you want hibernation.
  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
