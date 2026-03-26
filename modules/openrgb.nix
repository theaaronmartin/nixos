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

  systemd.services.openrgb-set-colors = {
    description = "Apply boot colors and reset ARGB zone sizes";
    # CRITICAL: Must run after the server starts or it will fail to connect
    after = [ "openrgb.service" ]; 
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5"; # Brief pause to let server detect all HID/I2C devices
      ExecStart = 
        let
          redish = "FF0026";
          purpleish = "A200FF";
          bin = "${pkgs.openrgb-with-all-plugins}/bin/openrgb";
        in
        "${bin} --device 0 --mode static --color ${redish} " +
        "--device 1 --mode static --color ${redish} " +
        "--device 2 --mode static --color ${redish} " +
        "--device 3 --zone 1 --size 30 --zone 2 --size 30 --mode static --color ${purpleish}";
    };
  };

  systemd.services.openrgb.after = [ "openrgb-ram-fix.service" ];
}
