# Shared networking: NetworkManager, SSH, and a minimal firewall.
#
# Docker moved to docker.nix and Nginx Proxy Manager to proxy.nix (2026-09-01).
# Previously this module opened 81/2234/4533/38080/38443 and started a reverse
# proxy on every host that imported it, including the laptop.
{
  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedTCPPorts = [
      22
    ];
  };
}
