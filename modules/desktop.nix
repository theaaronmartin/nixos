{ pkgs, pkgs-unstable, lib, ... }:
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

  # added 2026-09-01: mDNS so network printers are discoverable without manual
  # setup. This is what Bonjour was doing on the Windows install.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Browser. Waterfox (the laptop's daily driver) is not in nixpkgs; Firefox is
  # the chosen replacement. If you ever want the real thing, Flatpak is already
  # enabled below: flatpak install flathub net.waterfox.Waterfox
  programs.firefox.enable = true;

  # Flatpak support
  services.flatpak.enable = true;

  # added 2026-09-01: udev rules for flashing QMK boards.
  hardware.keyboard.qmk.enable = true;

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
    localsend
    beets
    picard
    rsgain
    # v11 to match the Windows install; nixpkgs 25.11 ships 10.3.1 and the
    # v10/v11 handshake is incompatible ("room not ready, maybe peer disconnected")
    pkgs-unstable.croc

    # --- added 2026-09-01 -------------------------------------------------
    # Daily drivers on the Windows laptop that were missing from the config.
    signal-desktop # running now and in Windows startup

    kdePackages.kdeconnect-kde # you use Phone Link on Windows
    kdePackages.okular
    wl-clipboard

    wireguard-tools
    networkmanager-openvpn
    qmk

    # Raster + vector editing. Bambu Studio is installed via Flatpak instead.
    gimp3
    inkscape

    # Windows VST2/VST3 bridge for REAPER. audio.nix already ships
    # wineWowPackages.staging; this is what actually lets Fractal/Neural DSP
    # style Windows plugins load. Note iLok-authorized plugins still will not
    # work - PACE has no Linux support.
    yabridge
    yabridgectl
  ];
}
