{ pkgs, lib, ... }:
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
  ];


  networking.hostName = "SHELL";

  environment.etc."wsl.conf".text = ''
    [boot]
    systemd=true

    [user]
    default=plague
  '';
  networking.nftables.enable = true;
  networking.networkmanager.enable = lib.mkForce false;
  networking.firewall.enable = lib.mkForce false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "plague"
  ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";

  # Intel CPU
  hardware.cpu.intel.updateMicrocode = true;

  # Intel Arc GPU
  services.xserver.videoDrivers = [ "modesetting" ];
  hardware.graphics.extraPackages = with pkgs; [ intel-media-driver ];
}
