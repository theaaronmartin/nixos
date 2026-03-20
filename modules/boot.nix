{ config, pkgs, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages;

  boot.kernelParams = [
    "processor.max_cstate=1"
    "rcu_nocbs=0-23"
    "idle=nomwait"
    "nvidia.NVreg_RegistryDwords=RMConnectToProtocol=1"
    "acpi_enforce_resources=lax"
  ];
  
  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "ee1004" ];
  boot.extraModprobeConfig = "";
}
