{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/boot.nix
    ../../modules/hardware.nix
    ../../modules/network.nix
    ../../modules/users.nix
    ../../modules/locale.nix
    ../../modules/audio.nix
    ../../modules/security.nix
    ../../modules/desktop.nix
    ../../modules/base.nix
    ../../modules/dev.nix
    ../../modules/work.nix
    ../../modules/wsl.nix
  ];

  networking.hostName = "SHELL";

  networking.nftables.enable = true;

  system.stateVersion = "25.11";

  # Intel CPU
  hardware.cpu.intel.updateMicrocode = true;

  # Intel Arc GPU
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];
}
