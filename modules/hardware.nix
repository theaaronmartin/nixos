{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.power-profiles-daemon.enable = false;

  powerManagement.cpuFreqGovernor = "performance";

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="244f", ATTRS{idProduct}=="0101", MODE="0660", GROUP="audio"
  '';

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    pipewire
    alsa-lib
    curl
    gnutls
    zlib
    libGL
    freetype
    glib
    xorg.libX11
    xorg.libXext
    xorg.libSM
    xorg.libICE
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXi
  ];
}
