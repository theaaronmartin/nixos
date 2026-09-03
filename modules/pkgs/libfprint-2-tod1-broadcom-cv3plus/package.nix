# Dell ControlVault 3+ fingerprint driver, pinned to 6.4.372-6.4.062.0.
#
# This is a vendored copy of the nixpkgs derivation with a newer `src`. It
# exists because the firmware bundled with the driver must MATCH the firmware
# already flashed on the sensor. nixpkgs ships 6.3.299-6.3.040.0, whose blobs
# are AAI 6.3.40.0 / SBI 134, while SHELL's sensor runs AAI 6.4.62.0 / SBI 247.
# The driver treats any mismatch as "needs upgrade", tried to flash the OLDER
# firmware over the newer one, and died:
#
#   Current AAI Version = 6.4.62.0 / Current SBI Version = 247
#   AAI version available for upgrade = 6.3.40.0 / SBI ... = 134
#   Updating ControlVault firmware from 6.4.62.0 to 6.3.40.0
#   Error: 0x47 from cv_flash_update()
#   Ignoring device due to initialization error
#
# 6.4.372-6.4.062.0 ships exactly AAI 6.4.62.0 / SBI 247, so the version check
# is a no-op and the device initialises instead of being reflashed.
#
# This cannot be done with overrideAttrs: wrapperLib bakes "${src}/var/lib/..."
# in at ITS build time, so overriding only the outer src would leave the
# wrapper pointing at the old firmware directory. Hence the full copy.
#
# When nixpkgs catches up to >= 6.4.372, delete this directory and go back to
# pkgs.libfprint-2-tod1-broadcom-cv3plus - but re-check the sensor's reported
# AAI/SBI in `journalctl -u fprintd` first.
{
  autoPatchelfHook,
  fetchgit,
  lib,
  libfprint-tod,
  openssl,
  patchelfUnstable,
  stdenv,
}:

let
  pname = "libfprint-2-tod1-broadcom-cv3plus";
  version = "6.4.372-6.4.062.0";

  src = fetchgit {
    url = "git://git.launchpad.net/~oem-solutions-engineers/pc-enablement/+git/libfprint-2-tod1-broadcom-cv3plus/";
    rev = "06f7f2f02f8443be685fd2b4667b7784ef2597b2"; # debian/6.4.372-6.4.062.0-0ubuntu1_oem3
    hash = "sha256-yKgjk0y7Eg5TBwwLqGs7NydS4O74iVlBbyMr0zq83kA=";
  };

  wrapperLibName = "wrapper-lib.so";
  wrapperLibSource = "wrapper-lib.c";

  # wraps `fopen()` for finding firmware files
  wrapperLib = stdenv.mkDerivation {
    pname = "${pname}-wrapper-lib";
    inherit version;

    src = builtins.path {
      name = "${pname}-wrapper-lib-source";
      path = ./.;
      filter = path: type: baseNameOf path == wrapperLibSource;
    };

    postPatch = ''
      substitute ${wrapperLibSource} lib.c \
        --subst-var-by to "${src}/var/lib/fprint/.broadcomCv3plusFW"
      cc -fPIC -shared lib.c -o ${wrapperLibName}
    '';

    installPhase = ''
      runHook preInstall
      install -D -t $out/lib ${wrapperLibName}
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  inherit src pname version;

  buildInputs = [
    libfprint-tod
    openssl
    wrapperLib
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    patchelfUnstable # have to use patchelfUnstable to support --rename-dynamic-symbols
  ];

  installPhase = ''
    runHook preInstall
    install -D -t "$out/lib/libfprint-2/tod-1/" -m 644 -v usr/lib/x86_64-linux-gnu/libfprint-2/tod-1/libfprint-2-tod-1-broadcom-cv3plus.so
    install -D -t "$out/lib/udev/rules.d/"      -m 644 -v lib/udev/rules.d/60-libfprint-2-device-broadcom-cv3plus.rules
    runHook postInstall
  '';

  postFixup = ''
    echo fopen64 fopen_wrapper > fopen_name_map
    patchelf \
      --rename-dynamic-symbols fopen_name_map \
      --add-needed ${wrapperLibName} \
      "$out/lib/libfprint-2/tod-1/libfprint-2-tod-1-broadcom-cv3plus.so"
  '';

  passthru.driverPath = "/lib/libfprint-2/tod-1";

  meta = with lib; {
    description = "Broadcom driver module for libfprint-2-tod Touch OEM Driver for Dell ControlVault v3+";
    homepage = "https://git.launchpad.net/~oem-solutions-engineers/pc-enablement/+git/libfprint-2-tod1-broadcom-cv3plus/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
