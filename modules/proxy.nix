# Nginx Proxy Manager. Split out of network.nix (2026-09-01).
# NIXCORE only - do not import on a laptop that roams onto untrusted networks.
{
  networking.firewall.allowedTCPPorts = [
    38080
    38443
    81
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers."nginx-proxy-manager" = {
      image = "jc21/nginx-proxy-manager:latest";
      ports = [
        "38080:80"
        "38443:443"
        "81:81"
      ];
      volumes = [
        "/var/lib/npm/data:/data"
        "/var/lib/npm/letsencrypt:/etc/letsencrypt"
      ];
      autoStart = true;
    };
  };
}
