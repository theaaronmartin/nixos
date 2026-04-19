{ pkgs, ... }: {
  # The Desktop Authenticator App
  environment.systemPackages = with pkgs; [
    yubioath-flutter
    yubikey-manager # Useful CLI tool (ykman) for troubleshooting
  ];

  # Required services for Yubikey hardware communication
  services.pcscd.enable = true; # Enable SmartCard daemon

  # Ensure udev rules are present so your user can access the USB device
  services.udev.packages = [ pkgs.yubikey-personalization ];
}
