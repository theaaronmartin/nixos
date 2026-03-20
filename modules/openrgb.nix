{ config, pkgs, ... }: {
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins;
  };

  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "ee1004" ];
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

  systemd.services.openrgb.after = [ "openrgb-ram-fix.service" ];
}
