{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Power policy moved out 2026-09-01. This module used to force the
  # "performance" governor and disable power-profiles-daemon on every host that
  # imported it, which is wrong for a laptop. See power-desktop.nix (NIXCORE)
  # and laptop.nix (SHELL).

  # NIXCORE hardware (ThrustMaster 244f:0101). Harmless elsewhere. Note the
  # laptop's MOTU M Series is 07fd:000b and is USB class-compliant, so it needs
  # no rule of its own.
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
