{ config, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;

  boot.extraModulePackages = [ config.boot.kernelPackages.zenpower ];

  boot.kernelParams = [
    "processor.max_cstate=1"
    "rcu_nocbs=0-23"
    "idle=nomwait"
    "nvidia.NVreg_RegistryDwords=RMConnectToProtocol=1"
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "acpi_enforce_resources=lax"
    "pcie_aspm=off"
  ];
  
  # boot.kernelModules = [ "i2c-dev" "i2c-piix4" "ee1004" ];
  boot.kernelModules = [ "zenpower" ];
  boot.blacklistedKernelModules = [ "k10temp" ];
  boot.extraModprobeConfig = "";
}
