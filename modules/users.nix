{ config, pkgs, ... }:
{
  users.users.plague = {
    isNormalUser = true;
    description = "Plague";
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
    packages = with pkgs; [
      vim
      vesktop
      bambu-studio
      feather
      nicotine-plus
      parted
      thunderbird
      opencode
    ];
  };

  # SSH Agent for your GitHub workflow
  programs.ssh.startAgent = true;
}
