{ ... }:
{
  users.users.plague = {
    isNormalUser = true;
    description = "Plague";
    shell = pkgs.zsh;
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
