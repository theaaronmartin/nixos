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
    ../../modules/native-instruments.nix
    ../../modules/security.nix
    ../../modules/star-citizen.nix
    ../../modules/games.nix
    ../../modules/ollama.nix
    ../../modules/comfyui.nix
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
    # 595.71.05, the only driver in nixos-26.05, does not compile against
    # kernel 7.2 (strncpy removed; nixpkgs issue #554125). Pin the current
    # production driver from nixpkgs master until 26.05 carries a fix.
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "595.104.02";
      sha256_64bit = "sha256-5CHCAuTHn1jDx/MWG75xRU67PYiTb4ggWg4yfNBMWco=";
      sha256_aarch64 = "sha256-PafStmwNMufeDp3VtpTGGCoW+53Gor/mieO1m1pI7gI=";
      openSha256 = "sha256-FWk5ra2yjz8VAxAA8GXrSoeBj/XC1BKvsKsBKR09joE=";
      settingsSha256 = "sha256-4Kxro6tvI5aX4nu2RspgyBsW+Jq3/VYjSAS5UGdzTCU=";
      persistencedSha256 = "sha256-JsMLPqJuZwAtHngsQODMsmgO7F2tVkQ2arc7fYa2bwo=";
    };
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
  boot.extraModulePackages = [
    # nixpkgs' 2025-12-20 zenpower3 snapshot fails on zen 7.2 with
    # "implicit declaration of function 'cpuid_ecx'"; upstream fixed the
    # include on 2026-06-30. Drop this override once nixpkgs carries it.
    (config.boot.kernelPackages.zenpower.overrideAttrs {
      version = "unstable-2026-06-30";
      src = pkgs.fetchFromGitHub {
        owner = "AliEmreSenel";
        repo = "zenpower3";
        rev = "faeb180492209db51a93ed24b30b2d3b2acf785d";
        hash = "sha256-zMR4CmOsrQti9uaZVbkXXLN140TjoTEwmHR4CJ73/0U=";
      };
    })
  ];
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
