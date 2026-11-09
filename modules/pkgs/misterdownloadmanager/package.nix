# Mister Download Manager - anefzaoui/misterdownloadmanager: an IDM-style
# segmented download manager in Rust (egui GUI + CLI + MCP server + browser
# native-messaging helper), with torrents and yt-dlp/gallery-dl video/gallery
# grabbing. GPL-3.0. Not in nixpkgs.
#
# Built from the upstream .deb rather than the tarball because the .deb also
# carries the .desktop file (with the magnet: handler), the icon and the
# unpacked Chromium extension. All four binaries link only glibc + libgcc_s +
# libm; everything graphical is dlopen()ed: winit's X11/Wayland/xkbcommon
# libs, libGL/libEGL or libvulkan, and libdbus. The names were read out of the
# 0.5.0 binary with `strings`. autoPatchelfHook's runtimeDependencies puts
# those libraries on the RUNPATH, so the dlopen() calls resolve without nix-ld.
# GTK is in the .deb's Depends: line but is not linked. MDM only reads GTK's
# settings.ini to pick a theme. No wrapGAppsHook is needed.
#
# Things that behave differently on NixOS:
# - Self-update. MDM decides how it was installed by asking dpkg/rpm/pacman.
#   None of them owns a store path, so it treats itself as the plain
#   tarball, and Help -> Update now tries to overwrite /nix/store and fails.
#   Bump `version` below instead.
# - Browser integration. MDM writes its native-messaging manifests itself on
#   every start (~/.mozilla/native-messaging-hosts, and
#   ~/.config/chromium/NativeMessagingHosts for ungoogled-chromium), naming
#   the store path of the copy that is running. After an upgrade and a GC
#   those manifests point at a path that no longer exists until MDM is
#   started once more. The extension then hands downloads back to the
#   browser, the same as when MDM is not running.
# - Helpers. MDM offers to download yt-dlp_linux and gallery-dl.bin, which
#   are PyInstaller builds that run here only through nix-ld. Use the nixpkgs
#   ones instead: open Helpers... -> Use another program... and pick
#   /run/current-system/sw/bin/{yt-dlp,gallery-dl}. On Linux, ffmpeg is
#   always the system's (from PATH). MDM only downloads its own on Windows.
#
# Version bumps:
#   gh release view -R anefzaoui/misterdownloadmanager --json tagName,assets \
#     --jq '.tagName, (.assets[] | select(.name|endswith("linux-x86_64.deb")) | .digest)'
#   nix hash convert --hash-algo sha256 --to sri <hex after "sha256:">
#   then re-check the dlopen() list:
#   strings -n 4 usr/bin/misterdownloadmanager | grep -aoE '[A-Za-z0-9_+-]+\.so(\.[0-9]+)*' | sort -u
{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, libxkbcommon
, wayland
, libx11
, libxcb
, libxcursor
, libxi
, libxrender
, vulkan-loader
, libGL
, dbus
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "misterdownloadmanager";
  version = "0.5.0";

  src = fetchurl {
    url = "https://github.com/anefzaoui/misterdownloadmanager/releases/download/v${finalAttrs.version}/MisterDownloadManager-${finalAttrs.version}-linux-x86_64.deb";
    hash = "sha256-6yPYwcV16nv2zpUZNJOtzMro/uT15BNfH1DHfgptePE=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook ];

  # libgcc_s (the only NEEDED entry besides glibc).
  buildInputs = [ stdenv.cc.cc.lib ];

  # dlopen()ed at runtime, so not NEEDED entries - added to RUNPATH instead.
  # libx11 also provides libX11-xcb; wayland provides libwayland-egl; libGL
  # is libglvnd (libGL + libEGL, dispatching to Mesa in /run/opengl-driver).
  runtimeDependencies = [
    libxkbcommon
    wayland
    libx11
    libxcb
    libxcursor
    libxi
    libxrender
    vulkan-loader
    libGL
    dbus.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  # Only usr/ is installed. The .deb's etc/ holds system-wide Chrome/Chromium/Edge
  # manifests, which would need environment.etc to mean anything here, and MDM
  # writes per-user manifests itself (see above). The Mozilla one is kept with
  # its path fixed, so programs.firefox.nativeMessagingHosts.packages can use
  # this package if that is ever wanted.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* $out/
    substituteInPlace $out/lib/mozilla/native-messaging-hosts/com.misterdownloadmanager.host.json \
      --replace-fail /usr/bin/ $out/bin/
    runHook postInstall
  '';

  meta = {
    description = "Segmented download manager with browser integration, torrents and video downloads";
    homepage = "https://github.com/anefzaoui/misterdownloadmanager";
    downloadPage = "https://github.com/anefzaoui/misterdownloadmanager/releases";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "misterdownloadmanager";
  };
})
