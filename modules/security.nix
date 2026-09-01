{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    (symlinkJoin {
      name = "yubioath-flutter-wrapped";
      paths = [ yubioath-flutter ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/yubioath-flutter \
          --set GDK_BACKEND "x11"
      '';
    })
    yubikey-manager # Useful CLI tool (ykman) for troubleshooting
    sops
    keepassxc
  ];

  # Required services for Yubikey hardware communication
  services.pcscd.enable = true; # Enable SmartCard daemon

  # Ensure udev rules are present so your user can access the USB device
  services.udev.packages = [ pkgs.yubikey-personalization pkgs.yubikey-manager ];
}
