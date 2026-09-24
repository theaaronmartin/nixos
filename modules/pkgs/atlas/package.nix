# Atlas - North American Motorsports Research's free ECU calibration suite for
# the FA20DIT / FA24DIT Subaru WRX (VA 2015-2021, VB 2022+).
#
# Upstream publishes no source build and no x86_64 tarball - the only amd64
# artifact is an AppImage - so this unpacks that release asset into an FHS
# environment instead of building from source.
#
# The AppImage is self-contained in the ways that matter: it bundles its own
# Temurin 21 JRE and the JOGL natives for the 3D table views, so nothing here
# provides Java. What it does NOT bundle is the X11 stack that AWT/Swing
# dlopens at runtime. programs.nix-ld (modules/hardware.nix) gets the bundled
# JRE far enough to start, but its library list has no libXrender, so running
# the AppImage bare dies with UnsatisfiedLinkError in Toolkit.<clinit>. The
# extraPkgs list below is what closes that gap - do not assume nix-ld covers it.
#
# Version bumps:
#   nix-prefetch-url --name Atlas_Linux_amd64.AppImage <url>
#   nix hash convert --hash-algo sha256 --to sri <printed hash>
#
# Expected noise when test-launching against a project: "Problem compiling"
# warnings for PowerPC:BE:32:VLE:MPC5746R and v850e3/v850e1m. Upstream's jar
# omits SPE_APU.sinc and vsx.sinc, which the MPC5746R SLEIGH specs @include (the
# V850 failure has no logged cause, and all of its includes are present). The
# bundled Ghidra file list was identical in 2026.2.7 and 2026.2.8. This is not
# the FHS wrapper or the read-only store, so don't try to fix it here.
{ lib
, appimageTools
, fetchurl
}:
let
  pname = "atlas";
  version = "2026.2.8";

  src = fetchurl {
    url = "https://github.com/motorsportsresearch/atlas-public/releases/download/${version}/Atlas_Linux_amd64.AppImage";
    hash = "sha256-ujov2YZKr3sNw6Pu+2KLHBDxyalngb60JHiDrUBUqaw=";
  };

  # Pulled out separately so the .desktop entry and icon can be lifted from the
  # image at build time rather than hand-written here.
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    # AWT/Swing dlopen these; libXrender is the one that actually breaks launch.
    xorg.libXrender
    xorg.libXtst
    xorg.libXxf86vm
    fontconfig
    freetype
    # JOGL, for the 3D table and gauge rendering.
    libGL
    libglvnd
  ];

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/Atlas.desktop \
      -t $out/share/applications
    install -Dm444 ${appimageContents}/Atlas.png \
      $out/share/icons/hicolor/128x128/apps/atlas.png

    # The shipped entry points at the in-image "Atlas" binary and an "Atlas"
    # icon name, neither of which exists once installed. Its Categories line
    # is also missing the trailing semicolon the spec requires.
    substituteInPlace $out/share/applications/Atlas.desktop \
      --replace-fail 'Exec=Atlas' 'Exec=atlas' \
      --replace-fail 'Icon=Atlas' 'Icon=atlas' \
      --replace-fail 'Categories=Utility' 'Categories=Utility;Development;'
  '';

  meta = {
    description = "Free ECU calibration and datalogging suite for the FA20DIT/FA24DIT Subaru WRX";
    homepage = "https://motorsportsresearch.org";
    downloadPage = "https://github.com/motorsportsresearch/atlas-public/releases";
    license = lib.licenses.unfree; # Closed-source freeware; only docs are on GitHub.
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "atlas";
  };
}
