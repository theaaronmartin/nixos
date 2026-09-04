# SHELL - Dell Precision 3490
# Core Ultra 5 135H (Meteor Lake, 14C/18T), Intel Arc iGPU (Xe-LPG, no dGPU),
# 63.5 GiB RAM, 2 TB Crucial P310 NVMe, Wi-Fi 6E AX211.
#
# Rebuilt 2026-09-01. This host was previously a NixOS-WSL config: its
# hardware-configuration.nix was generated inside WSL (9p mount of C:, wslg
# tmpfs, an empty boot.initrd.availableKernelModules) and it imported wsl.nix,
# which force-disabled NetworkManager and the firewall. It could not boot bare
# metal. The old WSL profile is preserved as
# hardware-configuration.nix.wsl.bak and in git history if you ever want to
# revive it as a separate SHELL-WSL host. (The .bak file has since been
# deleted; it is in git history at bb5fba5, not on disk.)
{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    # Exactly this machine. The bare `dell-precision-3490` module is deprecated
    # and aliases to the NVIDIA variant, so use -intel. This brings i915 in
    # initrd, intel-media-driver + intel-compute-runtime + vpl-gpu-rt (and their
    # 32-bit counterparts), hardware.cpu.intel.updateMicrocode as mkDefault, and
    # TLP-unless-power-profiles-daemon.
    inputs.nixos-hardware.nixosModules.dell-precision-3490-intel

    ../../modules/boot.nix
    ../../modules/hardware.nix
    ../../modules/laptop.nix
    ../../modules/network.nix
    ../../modules/docker.nix
    ../../modules/users.nix
    ../../modules/locale.nix
    ../../modules/audio.nix
    ../../modules/security.nix
    ../../modules/desktop.nix
    ../../modules/base.nix
    ../../modules/dev.nix
    ../../modules/mobile-dev.nix
    ../../modules/work.nix
    ../../modules/tui.nix
    ../../modules/syncthing.nix
    ../../modules/sops.nix
    # ../../modules/games.nix   # Steam/Epic/Lutris. Note it hardcodes
    #                           # /mnt/games/starsector, which does not exist
    #                           # here - guard play-starsector before importing.
  ];

  networking.hostName = "SHELL";
  networking.nftables.enable = true;

  system.stateVersion = "25.11";

  # Belt and braces: nixos-hardware sets this as mkDefault, gated on
  # hardware.enableRedistributableFirmware (which laptop.nix sets true).
  hardware.cpu.intel.updateMicrocode = true;

  # The GPU profile defaults vaapiDriver to null, meaning "install both iHD and
  # the legacy i965 driver". Xe-LPG wants iHD only.
  hardware.intelgpu.vaapiDriver = "intel-media-driver";
  # hardware.intelgpu.driver = "xe";  # optional; needs kernel >= 6.8, i915 is safe

  # Wayland session: better fractional scaling and touchpad gestures than X11.
  # Scoped to this host deliberately - NIXCORE is NVIDIA and stays on X11.
  services.displayManager.sddm.wayland.enable = true;

  # The factory Windows layout has a 100 MB ESP, which will not hold NixOS
  # generations (kernel + initrd runs 100-150 MB each). Point this at a NEW ~1 GB
  # ESP carved out of shrunk C: space, and keep the generation count low anyway.
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.systemd-boot.configurationLimit = 5;
}
