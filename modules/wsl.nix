{ lib, ... }:
{
  environment.etc."wsl.conf".text = ''
    [boot]
    systemd=true

    [user]
    default=plague
  '';
  networking.networkmanager.enable = lib.mkForce false;
  networking.firewall.enable = lib.mkForce false;
}
