{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/hardware.nix
    ../../modules/power-desktop.nix
    ../../modules/network.nix
    ../../modules/docker.nix
    ../../modules/proxy.nix
    ../../modules/media.nix
    ../../modules/openrgb.nix
    ../../modules/users.nix
    ../../modules/storage.nix
    ../../modules/desktop.nix
    ../../modules/locale.nix
    ../../modules/audio.nix
    ../../modules/security.nix
    ../../modules/star-citizen.nix
    ../../modules/games.nix
    ../../modules/ollama.nix
    ../../modules/base.nix
    ../../modules/dev.nix
    ../../modules/tui.nix
    ../../modules/syncthing.nix
    ../../modules/sops.nix
    ../../modules/sops-media.nix
  ];

  networking.hostName = "NIXCORE";
  networking.nftables.enable = true;
  networking.firewall.checkReversePath = "loose";

  system.stateVersion = "25.11";

  # added 2026-08-14: hardware freeze diagnosis. Moved here from boot.nix on
  # 2026-09-01 because it is NIXCORE-specific and consumes ESP space.
  boot.loader.systemd-boot.memtest86.enable = true;

  # Moved out of the shared network.nix on 2026-09-01 so SHELL stops inheriting
  # server ports. 38080/38443/81 now live in proxy.nix.
  networking.firewall.allowedTCPPorts = [
    4533 # Navidrome (services.navidrome.openFirewall also covers this)
    2234 # unidentified - was in the shared network.nix; confirm or drop
  ];
  networking.firewall.allowedUDPPorts = [
    1900 # SSDP/DLNA discovery
  ];

  # AMD CPU
  hardware.cpu.amd.updateMicrocode = true;

  # NVIDIA GPU
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
  };
  hardware.nvidia-container-toolkit.enable = true;
  environment.systemPackages = with pkgs; [
    zenmonitor
    cudaPackages.cudatoolkit
  ];
  environment.sessionVariables = {
    # KWIN_DRM_NO_AMS = "1";  # disabled 2026-08-14: forced legacy KMS, broke NVIDIA atomic modesetting
    POWERDEVIL_NO_DDCUTIL = "1";
  };

  # Zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
  boot.kernelParams = [
    "processor.max_cstate=1"
    "rcu_nocbs=0-23"
    "idle=nomwait"
    "nvidia.NVreg_RegistryDwords=RMConnectToProtocol=1"
    "nvidia.NVreg_EnableGpuFirmware=0"
    "acpi_enforce_resources=lax"
    "pcie_aspm=off"
    "amd_pstate=passive"
    "initcall_blacklist=acpi_cppc_init"
  ];
  boot.kernelModules = [
    "zenpower"
    "msr"
  ];
  boot.blacklistedKernelModules = [ "k10temp" "iwlwifi" ];

  # added 2026-08-14: decode MCE/RAS hardware errors (data fabric sync flood investigation)
  hardware.rasdaemon.enable = true;
}
