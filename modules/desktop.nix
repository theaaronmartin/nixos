{ pkgs, lib, ... }:
{
  # Graphical Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
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

  # Flatpak support
  services.flatpak.enable = true;

  # Add flatpak export directories to XDG_DATA_DIRS
  # Append to existing XDG_DATA_DIRS list
  environment.sessionVariables.XDG_DATA_DIRS = lib.mkAfter [
    "/var/lib/flatpak/exports/share"
    "/home/plague/.local/share/flatpak/exports/share"
  ];

  # Desktop applications from users.nix and home.nix
  environment.systemPackages = with pkgs; [
    discord-canary
    feather
    nicotine-plus
    thunderbird
    libreoffice-qt-fresh
    hunspell
    hunspellDicts.en_US-large
    obsidian
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
