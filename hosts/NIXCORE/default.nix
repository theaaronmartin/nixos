{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/hardware.nix
    ../../modules/network.nix
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
  ];

  networking.hostName = "NIXCORE";
  networking.nftables.enable = true;
  networking.firewall.checkReversePath = "loose";

  system.stateVersion = "25.11";

  # AMD CPU
  hardware.cpu.amd.updateMicrocode = true;

  # NVIDIA GPU
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    nvidiaPersistenced = false;
  };
  hardware.nvidia-container-toolkit.enable = true;
  environment.systemPackages = with pkgs; [
    zenmonitor
    cudaPackages.cudatoolkit
  ];

  # Zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];
  boot.kernelParams = [
    "processor.max_cstate=1"
    "rcu_nocbs=0-23"
    "idle=nomwait"
    "nvidia.NVreg_RegistryDwords=RMConnectToProtocol=1"
    "nvidia.NVreg_EnableGpuFirmware=0"
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "acpi_enforce_resources=lax"
    "pcie_aspm=off"
    "amd_pstate=passive"
    "amd_pstate.epp=performance"
  ];
  boot.kernelModules = [
    "zenpower"
    "msr"
  ];
  boot.blacklistedKernelModules = [ "k10temp" ];
}
