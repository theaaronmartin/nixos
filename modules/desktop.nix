{ pkgs, ... }:
{
  # Graphical Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    config.common.default = "kde";
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # Browser
  programs.firefox.enable = true;

  # Desktop applications from users.nix and home.nix
  environment.systemPackages = with pkgs; [
    vesktop
    bambu-studio
    feather
    nicotine-plus
    thunderbird
    libreoffice-qt-fresh
    hunspell
    hunspellDicts.en_US-large
  ];

  # Vesktop Autostart
  systemd.user.services.vesktop = {
    description = "Vesktop Discord Client (Delayed Start)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = ''
        ${pkgs.vesktop}/bin/vesktop \
          --start-minimized \
          --enable-features=UseOzonePlatform,WebRTCPipeWireCapturer \
          --ozone-platform=wayland
      '';
      Restart = "on-failure";
    };
  };
}
