{ pkgs, pkgs-unstable, lib, ... }:
let
  # added 2026-09-02: SDDM login screen background. This is NOT the Plasma lock
  # screen (that one is per-user in ~/.config/kscreenlockerrc, set from System
  # Settings -> Security & Privacy -> Screen Locking). SDDM has no GUI for it:
  # breeze's theme.conf hardcodes `background` as an absolute path into the
  # read-only store, and SDDM's theme.conf.user override would have to live in
  # that same unwritable directory. So copy the theme out of plasma-desktop and
  # repoint it at our own wallpaper.
  sddmBreezeCustom = pkgs.runCommandLocal "sddm-breeze-plague" { } ''
    theme="$out/share/sddm/themes/breeze-plague"
    mkdir -p "$(dirname "$theme")"
    cp -r ${pkgs.kdePackages.plasma-desktop}/share/sddm/themes/breeze "$theme"
    chmod -R u+w "$theme"
    cp ${../dotfiles/assets/ghost_in_the_shell.png} "$theme/background.png"
    sed -i "s|^background=.*|background=$theme/background.png|" "$theme/theme.conf"
  '';
in
{
  # Graphical Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Full path rather than a bare theme name, so it does not have to be installed
  # into systemPackages to be found under ThemeDir.
  services.displayManager.sddm.theme = "${sddmBreezeCustom}/share/sddm/themes/breeze-plague";

  # The sddm module only applies these when `theme` is the literal string
  # "breeze", which the path above is not. Restore them by hand.
  services.displayManager.sddm.settings.Theme = {
    CursorTheme = "breeze_cursors";
    CursorSize = 24;
  };

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

  # Your Phone Link replacement. This has to be the module rather than just the
  # kdeconnect-kde package: discovery is a UDP broadcast on 1716 and pairing
  # then runs over TCP, but network.nix keeps the firewall on with only 22
  # open, so a bare package install can never see the phone. Enabling this
  # opens 1714-1764 on both TCP and UDP, which is all it needs.
  programs.kdeconnect.enable = true;

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
    # Signal Desktop hard-expires ~90 days after release and then refuses to
    # start at all. nixpkgs 25.11 is pinned at 8.4.1 and even the branch tip
    # only has 8.9.1, so stable is permanently behind the expiry window.
    # Needs a `nix flake update nixpkgs-unstable` every couple of months.
    pkgs-unstable.signal-desktop # running now and in Windows startup

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

    # --- added 2026-09-04 -------------------------------------------------
    # Official Jellyfin desktop client. Decodes with mpv, so it direct-plays
    # whatever the file already is and the server never transcodes.
    #
    # Firefox is the reason this is here. Jellyfin picks its playback method
    # from a device profile the web client builds by probing the browser, and
    # Firefox claimed HEVC support it could not deliver -- so Jellyfin copied
    # the 10-bit HEVC video stream through untouched and playback froze a few
    # seconds in, with no error on the server side. Disabling remuxing in the
    # Jellyfin user policy does NOT prevent this: the web client requests
    # stream-copy directly on the HLS endpoint and Jellyfin honours it.
    # Verified 2026-09-04 the same files play fine on the TV (Litefin, direct
    # play, zero ffmpeg processes) and via a forced transcode to 8-bit h264.
    jellyfin-media-player
  ];
}
