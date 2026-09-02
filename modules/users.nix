{ pkgs, ... }:
{
  users.users.plague = with pkgs; {
    isNormalUser = true;
    description = "Plague";
    shell = zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "render"
      "media"
      "docker"
      "i2c"
      "input"
    ];
    openssh.authorizedKeys.keys = [
      # SHELL (Dell Precision 3490) - generated 2026-09-02 after the Windows -> NixOS migration
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANN0G6vR+bngScAqDKx+QB+cmNW1Wr2wp6LgMYvJD56 aaron@notaaron.com"
    ];
  };

  # SSH Agent for your GitHub workflow
  programs.ssh.startAgent = true;
}
