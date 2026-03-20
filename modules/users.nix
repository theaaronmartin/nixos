{ config, pkgs, ... }: {
  users.users.plague = {
    isNormalUser = true;
    description = "Plague";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "media" "docker" "i2c" ];
    packages = with pkgs; [
      vim
      wget
      curl
      git
      vesktop
      bambu-studio
    ];
  };

  # SSH Agent for your GitHub workflow
  programs.ssh.startAgent = true;
}
