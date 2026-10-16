# webOS Dev Manager - webosbrew's GUI for LG TVs in Developer Mode (or rooted):
# add a TV, install/launch .ipk apps, renew the dev-mode session, browse files.
# Not in nixpkgs.
#
# Built from the upstream .deb rather than the AppImage. It is a Tauri app, so
# the .deb is a single Rust binary that dynamically links the system
# WebKitGTK 4.1 / GTK3 / libsoup 3 (see the deb's Depends: line). Patching that
# against nixpkgs' webkitgtk is ~13 MB of download and uses the same WebKit
# build as everything else on the box; the 80 MB AppImage instead bundles its
# own WebKit and Mesa. This build does not render on NIXCORE's NVIDIA card
# (the AppImage was never tried there); see hosts/SHELL/default.nix.
#
# Device config is ares-cli compatible: it lives in ~/.webos/ares/ and the SSH
# keys it fetches from the TV go in ~/.ssh/. Talking to a TV is outbound only
# (SSH on the TV's :9922, key download from its :9991), so no firewall change.
#
# Version bumps:
#   gh api repos/webosbrew/dev-manager-desktop/releases/latest \
#     --jq '.assets[] | select(.name | endswith("_amd64.deb")) | .digest'
#   nix hash convert --hash-algo sha256 --to sri <hex after "sha256:">
{ lib
, stdenv
, fetchurl
, dpkg
, autoPatchelfHook
, wrapGAppsHook3
, webkitgtk_4_1
, gtk3
, libsoup_3
, glib
, glib-networking
, cairo
, gdk-pixbuf
, zlib
, gst_all_1
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "webos-dev-manager";
  version = "1.99.20";

  src = fetchurl {
    url = "https://github.com/webosbrew/dev-manager-desktop/releases/download/v${finalAttrs.version}/webos-dev-manager_${finalAttrs.version}_amd64.deb";
    hash = "sha256-o+L6SeRgZDuehXdStNVdHctYciQP+nVeXnr+HQF5EsI=";
  };

  nativeBuildInputs = [ dpkg autoPatchelfHook wrapGAppsHook3 ];

  buildInputs = [
    webkitgtk_4_1
    gtk3
    libsoup_3
    glib
    # TLS for libsoup - the app fetches the Homebrew Channel repo over HTTPS.
    glib-networking
    cairo
    gdk-pixbuf
    zlib
    # WebKit's media backend; without these it logs "GStreamer element
    # appsink not found" on every launch.
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r usr/* $out/
    runHook postInstall
  '';

  meta = {
    description = "Device and Developer Mode manager for LG webOS TVs";
    homepage = "https://github.com/webosbrew/dev-manager-desktop";
    downloadPage = "https://github.com/webosbrew/dev-manager-desktop/releases";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "webos-dev-manager";
  };
})
