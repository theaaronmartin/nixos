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
