# Laptop hardware + power policy. SHELL only.
# NIXCORE gets power-desktop.nix instead; both were previously tangled into
# hardware.nix, which pinned the CPU governor to "performance" on every host.
{ pkgs, ... }:
let
  # Pinned to 6.4.372-6.4.062.0 to match the firmware already on the sensor.
  broadcomCv3plus = pkgs.callPackage ./pkgs/libfprint-2-tod1-broadcom-cv3plus/package.nix { };

  # On 2026-10-02 the Dell EC stopped updating charge_now on battery: it kept
  # reporting the "100%" placeholder it shows while docked, so there was no
  # low-battery warning and the laptop died "at 100%". A power drain (AC and
  # dock unplugged, power button held ~20 s) cleared it. This watches for a
  # recurrence: on battery, it integrates current_now and alerts once ~50 mAh
  # (~1.4%) has been drawn without charge_now moving. Integrating current
  # rather than counting minutes means it can't fire when the laptop is idle
  # or suspended.
  # BATTERY_WATCH_SYSFS and BATTERY_WATCH_INTERVAL exist only for testing it
  # against fake files.
  batteryFreezeWatch = pkgs.writeShellApplication {
    name = "battery-freeze-watch";
    runtimeInputs = [ pkgs.coreutils pkgs.libnotify ];
    text = ''
      sysfs="''${BATTERY_WATCH_SYSFS:-/sys/class/power_supply}"
      interval="''${BATTERY_WATCH_INTERVAL:-30}"
      limit_uah=50000

      rd() { cat "$1" 2>/dev/null || true; }

      last=""
      drawn=0
      alerted=0
      while true; do
        if [ "$(rd "$sysfs/AC/online")" = 1 ]; then
          last=""
          drawn=0
          alerted=0
        else
          now="$(rd "$sysfs/BAT0/charge_now")"
          cur="$(rd "$sysfs/BAT0/current_now")"
          if [ -n "$now" ] && [ -n "$cur" ]; then
            if [ "$now" != "$last" ]; then
              last="$now"
              drawn=0
            else
              drawn=$((drawn + cur * interval / 3600))
              if [ "$drawn" -ge "$limit_uah" ] && [ "$alerted" = 0 ]; then
                echo "charge_now stuck at $now after ~$((drawn / 1000)) mAh drawn"
                notify-send -u critical -a "Battery watch" -i battery-caution \
                  "Battery % is frozen" \
                  "About $((drawn / 1000)) mAh drawn and the reading hasn't moved, so you won't get a low-battery warning. Plug in, then shut down, unplug, hold power 20 s." ||
                  echo "notify-send failed"
                alerted=1
              fi
            fi
          fi
        fi
        sleep "$interval"
      done
    '';
  };
in
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

  systemd.user.services.battery-freeze-watch = {
    description = "Warn when the battery percentage stops counting down on battery";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${batteryFreezeWatch}/bin/battery-freeze-watch";
      Restart = "on-failure";
      RestartSec = 30;
    };
  };

  # Docked to the ATEN KVM most of the time, so don't suspend on lid close while
  # on external power.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };

  # Fingerprint reader: Dell ControlVault 3+, USB 0a5c:5865.
  #
  # The obvious package, libfprint-2-tod1-broadcom, is the WRONG one - it is
  # ControlVault 3 (non-plus) and its id_table only covers 0a5c:5840-5845, in
  # both the nixpkgs version and the newest upstream (5.15.021.0). Broadcom
  # ships CV3+ as a separate blob, libfprint-2-tod1-broadcom-cv3plus, whose
  # id_table is 0a5c:5860/5863/5864/5865/5866/5867. Verified by dumping the
  # id_table out of both .so files - do not "simplify" this back to the
  # non-plus package.
  #
  # The driver fopen()s its firmware from a hardcoded
  # /var/lib/fprint/.broadcomCv3plusFW; the derivation handles that by
  # patchelf-renaming fopen64 to a wrapper that rewrites the path into the
  # store, so no state needs to exist under /var/lib/fprint.
  #
  # NOT pkgs.libfprint-2-tod1-broadcom-cv3plus: nixpkgs is on 6.3.040.0, whose
  # bundled firmware (AAI 6.3.40.0 / SBI 247 -> 134) is OLDER than what this
  # sensor is already flashed with, and the driver responds to any mismatch by
  # trying to reflash it downwards, failing with 0x47, and dropping the device.
  # See modules/pkgs/libfprint-2-tod1-broadcom-cv3plus/package.nix.
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = broadcomCv3plus;

  # The fprintd module wires FP_TOD_DRIVERS_DIR but does not install the
  # driver's udev rules, which set the sensor's runtime PM to "auto" and tag it
  # with LIBFPRINT_DRIVER. Add them explicitly.
  services.udev.packages = [ broadcomCv3plus ];

  # DO NOT swap broadcomCv3plus for pkgs.libfprint-2-tod1-broadcom-cv3plus.
  # This driver reflashes the sensor on every init whenever the firmware it
  # bundles differs from what the chip reports - including downgrades. nixpkgs
  # is on 6.3.040.0 (AAI 6.3.40.0 / SBI 134); this sensor runs 6.4.62.0 / 247.
  # Using the nixpkgs one on 2026-09-03 cleared the SCD, reset the chip into
  # SBI mode, failed the write with 0x47, and left it dead at 0a5c:5860 /
  # class 0xff. Recovery was the pinned 6.4.062.0 driver below, which found the
  # chip in SBI mode and reflashed it correctly ("Control Vault firmware
  # upgrade successful"), restoring 0a5c:5865 / class 0xfe.
  #
  # Sensor is a Goodix GF5288 (GF5288_GM188WNC_APP_21003) behind the
  # ControlVault; device and driver firmware now match exactly, so startup is a
  # version check and no flash. Before ever bumping this pin, compare the
  # candidate's var/lib/fprint/.broadcomCv3plusFW/bcm_cv_current_version.txt
  # against what `journalctl -u fprintd` reports as "Current AAI Version".

  # security.pam.services.*.fprintAuth defaults to services.fprintd.enable, so
  # this lands in every PAM stack as "sufficient" ahead of pam_unix: a finger
  # works, and anything else falls through to the password prompt.

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
