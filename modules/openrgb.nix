{ config, lib, pkgs, pkgs-unstable, ... }:
{
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs-unstable.openrgb-with-all-plugins;
  };

  boot.kernelModules = [
    "i2c-dev"
    "i2c-piix4"
    "ee1004"
  ];
  hardware.i2c.enable = true;
  users.groups.i2c.members = [ "plague" ];

  systemd.services.openrgb-ram-fix = {
    description = "Unbind RAM from ee1004 driver for OpenRGB";
    before = [ "openrgb.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeScript "unbind-ram" ''
        #!${pkgs.bash}/bin/bash
        # Target the four slots on SMBus port 0 (addresses 50-53)
        echo "0-0050" > /sys/bus/i2c/drivers/ee1004/unbind || true
        echo "0-0051" > /sys/bus/i2c/drivers/ee1004/unbind || true
        echo "0-0052" > /sys/bus/i2c/drivers/ee1004/unbind || true
        echo "0-0053" > /sys/bus/i2c/drivers/ee1004/unbind || true
      '';
    };
  };

  systemd.services.openrgb-set-colors = {
    description = "Apply boot colors and reset ARGB zone sizes";
    # CRITICAL: Must run after the server starts or it will fail to connect
    after = [ "openrgb.service" ];
    wantedBy = [ "multi-user.target" ];
    # The server enumerates the six controllers over several seconds after it
    # starts. A fixed 5 s pause was losing the race to the NZXT fan controller
    # on every boot since at least 2026-09-21, and the client then died with
    # "Empty device ID" (now, with names, `Cannot find device "..."`). Give it
    # longer, and retry on failure rather than leaving the lights unset for the
    # whole session.
    startLimitIntervalSec = 120;
    startLimitBurst = 6;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 5;
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      ExecStart =
        let
          # Previous scheme, unused for now — kept to switch back to.
          redish = "C80002";
          purpleish = "5D00FF";
          yellowish = "F0FF00"; # rgb(240, 255, 0)
          # Read live off device 3 on 2026-11-10. Device 5 was still on the old
          # 5D00FF purple, but its Hue 2 channels report 0 LEDs, so the blue on
          # show was coming from the motherboard.
          blueish = "0000FF";
          bin = "${pkgs-unstable.openrgb-with-all-plugins}/bin/openrgb";
          # Devices are picked by name, not index. The mouse is on a KVM shared
          # with SHELL, so if NIXCORE boots while it points there the mouse is
          # missing and every index after it shifts. `--device "name"` is a
          # case-insensitive substring match that selects *every* device
          # containing it, so keep each one unique: bare "NZXT" would hit both
          # the Kraken and the fan controller.
          set =
            name: mode: color:
            ''--device "${name}" --mode ${mode} --color ${color}'';
        in
        [
          # If any name is not found the CLI exits 255 before applying anything,
          # so a failure here means the server is still enumerating, and
          # Restart= retries the unit.
          (lib.concatStringsSep " " [
            bin
            (set "Kingston Fury" "static" yellowish)
            (set "RTX 3080" "static" yellowish)
            (set "Kraken" "static" yellowish)
            (set "Crosshair" "static" blueish)
            (set "Fan Controller" "static" blueish)
          ])
          # The mouse gets its own step, and the leading "-" lets it fail when the
          # KVM points at SHELL. It has enumerated before the fan controller on
          # every run seen so far, so once the step above succeeds it is there if
          # it is plugged in. The Model O has no Static mode: `--mode static`
          # prints an error but exits 0, and the mouse silently keeps its old
          # colour. Custom is its single-colour mode.
          "-${bin} ${set "Model O" "custom" yellowish}"
        ];
    };
  };

  systemd.services.openrgb.after = [ "openrgb-ram-fix.service" ];
}
