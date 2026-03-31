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
    ];
  };

  # SSH Agent for your GitHub workflow
  programs.ssh.startAgent = true;

  systemd.user.services.vesktop = {
    description = "Vesktop Discord Client (Delayed Start)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.vesktop}/bin/vesktop --start-minimized";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
