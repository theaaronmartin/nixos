{ config, pkgs, ... }: {
  users.users.plague = {
    isNormalUser = true;
    description = "Plague";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "render" "media" "docker" "i2c" ];
    packages = with pkgs; [
      vim
      wget
      curl
      git
      vesktop
      bambu-studio
      feather
      nicotine-plus
    ];
  };

  # SSH Agent for your GitHub workflow
  programs.ssh.startAgent = true;
}
