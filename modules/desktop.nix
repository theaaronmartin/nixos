{ config, pkgs, ... }: {
  # Graphical Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;
  
  # Browser
  programs.firefox.enable = true;

  # Vesktop Autostart
  systemd.user.services.vesktop = {
    description = "Vesktop Discord Client (Delayed Start)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.vesktop}/bin/vesktop --start-minimized";
      Restart = "on-failure";
    };
  };
}
