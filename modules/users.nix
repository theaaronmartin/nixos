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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGfu6dcgYwdJf9VerwwzTV5xhn034uY9Up3qTv71eA5o amartin@ultrasignup.com"
    ];
  };

  # SSH Agent for your GitHub workflow
  programs.ssh.startAgent = true;
}
