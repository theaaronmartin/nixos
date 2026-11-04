# Craft Anything - storytold/craft-anything: a pure-Rust reverse-engineering
# engine (egui desktop app + CLI + MCP server) that studies a website/app/game
# and has a coding agent (Claude Code first) rebuild it. Not in nixpkgs.
#
# Built from the upstream linux-x86_64 tarball, which is already an FHS tree
# (bin/craft-anything, bin/craft-anything-cli, share/{applications,icons,...}).
# Both binaries link only glibc + libgcc_s; everything graphical is dlopen()ed
# (upstream lists the set in packaging/linux/nfpm.yaml: winit's X11/Wayland/
# xkbcommon libs, and libvulkan or libEGL for wgpu). autoPatchelfHook's
# runtimeDependencies puts those on the RUNPATH so the dlopen()s resolve
# without leaning on nix-ld. Mesa/ANV come from /run/opengl-driver as usual.
#
# Building needs `claude` on PATH (it runs the user's own install). Optional
# engines (Ghidra, a Chromium-based browser for website capture, gdb, ...) are
# found on PATH at runtime; `craft-anything-cli doctor` lists them.
#
# Version bumps:
#   gh release view -R storytold/craft-anything --json tagName,assets \
#     --jq '.tagName, (.assets[] | select(.name|endswith("linux-x86_64.tar.gz")) | .digest)'
#   nix hash convert --hash-algo sha256 --to sri <hex after "sha256:">
{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, libxkbcommon
, wayland
, libx11
, libxcb
, libxcursor
, libxi
, vulkan-loader
, libGL
, dbus
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "craft-anything";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/storytold/craft-anything/releases/download/v${finalAttrs.version}/craft-anything-${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-Z07Fn/va771XeRfgfJ1GRWIEOydaOIm6T2AjmhLwPVM=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  # libgcc_s (the only non-glibc NEEDED entry).
  buildInputs = [ stdenv.cc.cc.lib ];

  # dlopen()ed at runtime, so not NEEDED entries - added to RUNPATH instead.
  runtimeDependencies = [
    libxkbcommon
    wayland
    libx11
    libxcb
    libxcursor
    libxi
    vulkan-loader
    libGL
    dbus.lib
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r bin share $out/
    runHook postInstall
  '';

  meta = {
    description = "See how any website, app or game works, then have AI build your own version";
    homepage = "https://github.com/storytold/craft-anything";
    license = with lib.licenses; [ mit asl20 ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "craft-anything";
  };
})
