# Vehicle ECU tuning. SHELL only - the laptop is the machine that actually goes
# out to the car, and NIXCORE has no reason to carry a 1 GB AppImage closure.
#
# Atlas (modules/pkgs/atlas) talks to the car over a USB adapter using a serial
# driver written into Atlas itself, NOT a J2534 passthru library. That is the
# whole reason this works on Linux at all: there is no Linux j2534 .so to
# install, and vendor J2534 drivers must be *absent* rather than present. All
# the OS has to supply is a tty the user can open.
#
# NAMR supports exactly three adapters. Only the Tactrix needs anything from
# this module beyond the dialout membership:
#
#   OBDX Pro VX   USB/WiFi/BT   60-100 Hz   flash 20s-5m   CDC -> ttyACM*
#   Tactrix OP2.0 USB only      60-100 Hz   flash 1-5m     needs the rule below
#   OBDLink EX    USB only      20-60 Hz    flash 1-10m    FTDI -> ttyUSB*
#
# The OBDLink EX ships an STN2120 behind a stock FTDI product ID and the OBDX
# Pro VX enumerates as USB CDC, so the kernel binds both unaided and dialout is
# all they need. The Tactrix Openport 2.0 is the exception: USB 0403:cc4d is an
# FTDI vendor ID with a custom product ID that is not in ftdi_sio's device
# table, so the kernel binds nothing and no /dev/ttyUSB* ever appears. The rule
# below registers the PID through ftdi_sio's new_id sysfs hook on plug-in,
# which is the modern replacement for the removed `modprobe ftdi_sio vendor=
# product=` parameters.
#
# NB for the VB: an OBDLink EX needs firmware newer than its original release
# to flash a 2022+ VB WRX, and OBD Solutions' STN updater is a Windows-only
# .exe. Nothing in this module can work around that - it is a reason to prefer
# one of the other two adapters on a Linux-only machine.
{ pkgs, ... }:
{
  environment.systemPackages = [
    (pkgs.callPackage ./pkgs/atlas/package.nix { })
  ];

  # Lets a bare .AppImage be executed directly, so an Atlas nightly or a
  # release newer than the pinned one can be run from ~/Downloads without
  # waiting on a flake bump.
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Must be resident before the udev rule below can write to its new_id.
  boot.kernelModules = [ "ftdi_sio" ];

  # Merges with the ThrustMaster rule in hardware.nix - services.udev.extraRules
  # is a lines-typed option, so both definitions are concatenated.
  services.udev.extraRules = ''
    # Tactrix Openport 2.0 - bind it to ftdi_sio so it shows up as ttyUSB*.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="cc4d", RUN+="${pkgs.bash}/bin/bash -c 'echo 0403 cc4d > /sys/bus/usb-serial/drivers/ftdi_sio/new_id'"
    # ...and make the resulting tty openable without root.
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="cc4d", MODE="0660", GROUP="dialout", TAG+="uaccess"
    # Openport 2.0 in bootloader mode (0403:cc4b), for ECU recovery flashes.
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="cc4b", MODE="0660", GROUP="dialout", TAG+="uaccess"
  '';

  # Covers the Tactrix tty above and any OBDLink/ELM327 serial adapter.
  users.users.plague.extraGroups = [ "dialout" ];
}
