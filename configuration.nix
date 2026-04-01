{ config, pkgs, lib, inputs, pkgs-unstable, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/network.nix
    ./modules/media.nix
    ./modules/openrgb.nix
    ./modules/users.nix
    ./modules/storage.nix
    ./modules/desktop.nix
    ./modules/locale.nix
    ./modules/audio.nix
    ./modules/security.nix
    ./modules/star-citizen.nix
    ./modules/games.nix
  ];

  networking.hostName = "NIXCORE";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "plague" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
}
