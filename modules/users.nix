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
  };

  # SSH Agent for your GitHub workflow
  programs.ssh.startAgent = true;
}
