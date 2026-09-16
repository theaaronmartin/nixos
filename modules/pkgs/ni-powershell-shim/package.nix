# A stand-in powershell.exe for Native Instruments installers running in wine.
#
# Wine's own powershell.exe is a stub that returns 0 for everything. NI's
# installer uses it to ask "is Native Access already running?", reads 0 as
# "yes", and aborts + rolls back. Without this shim Native Access cannot be
# installed under wine at all. See powershell-shim.c for the exact probes.
#
# Built for both architectures: a 64-bit build for system32 and a 32-bit one
# for syswow64, because NI's installers are 32-bit PE and get redirected.
#
# -static-libgcc rather than -static: a full static link wants libmcfgthread,
# which is not on the link path in the sandbox. The shim only calls
# GetCommandLineA and strstr, so it needs nothing wine does not already have.
{ runCommand, pkgsCross }:

let
  build = crossPkgs: exeName:
    crossPkgs.stdenv.mkDerivation {
      pname = "ni-powershell-shim-${exeName}";
      version = "1";
      src = ./.;
      dontConfigure = true;

      buildPhase = ''
        runHook preBuild
        $CC -O2 -mconsole -static-libgcc -o ${exeName} powershell-shim.c
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p "$out/bin"
        cp ${exeName} "$out/bin/"
        runHook postInstall
      '';
    };

  w64 = build pkgsCross.mingwW64 "powershell64.exe";
  w32 = build pkgsCross.mingw32 "powershell32.exe";
in
runCommand "ni-powershell-shim"
{
  meta.description = "powershell.exe stand-in so NI installers work under wine";
}
  ''
    mkdir -p "$out/bin"
    cp ${w64}/bin/powershell64.exe ${w32}/bin/powershell32.exe "$out/bin/"
  ''
