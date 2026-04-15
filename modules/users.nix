{ ... }:
{
  users.users.plague = {
    isNormalUser = true;
    description = "Plague";
    initialHashedPassword = "$y$j9T$xwlbEHAgV/ip4xWwVzQA30$PSAX1k/LMhOylpyvmzc2PcX9Dj4DIAkoq0N7dy3JYT1";
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
