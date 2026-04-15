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
  ];

  networking.hostName = "SHELL";
  networking.nftables.enable = true;

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
}
