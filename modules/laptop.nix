# Laptop hardware + power policy. SHELL only.
# NIXCORE gets power-desktop.nix instead; both were previously tangled into
# hardware.nix, which pinned the CPU governor to "performance" on every host.
{ pkgs, ... }:
{
  # Firmware for the AX211 Wi-Fi 6E / Bluetooth radio and Meteor Lake SOF audio.
  # A generated hardware-configuration.nix normally pulls this in via
  # not-detected.nix, but SHELL's old WSL profile had an empty imports list and
  # therefore never enabled it. Set it explicitly so it doesn't depend on that.
  # nixos-hardware's meteor-lake profile also gates cpu.intel.updateMicrocode on
  # this flag.
  hardware.enableRedistributableFirmware = true;

  # Leave powerManagement.cpuFreqGovernor unset. Under intel_pstate active mode
  # the only governors are powersave/performance; power-profiles-daemon switches
  # the energy-performance preference instead, which is what Plasma 6's power
  # widget drives.
  services.power-profiles-daemon.enable = true;

  # nixos-hardware's common/pc/laptop enables TLP whenever PPD is off. PPD is on
  # above, so TLP stays off. Do not run both.
  services.tlp.enable = false;

  services.thermald.enable = true; # matters a lot on Intel laptops
  powerManagement.enable = true;
  zramSwap.enable = true;

  services.fwupd.enable = true; # Dell publishes BIOS/firmware via LVFS
  services.upower.enable = true;
  hardware.sensor.iio.enable = true; # ambient light sensor / accelerometer

  # Docked to the ATEN KVM most of the time, so don't suspend on lid close while
  # on external power.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };

  # Dell ControlVault 3+ (0a5c:5865). libfprint-2-tod1-broadcom is packaged but
  # ControlVault support is inconsistent. Left off deliberately: a half-working
  # fprintd lands in the PAM stack and can make login painful. Try it once the
  # system is otherwise up.
  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-broadcom;

  environment.systemPackages = with pkgs; [
    brightnessctl
    powertop
    acpi
    # Intel Arc diagnostics
    libva-utils
    intel-gpu-tools
    vulkan-tools
    clinfo
  ];
}
