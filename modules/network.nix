{ ... }:
{

  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedTCPPorts = [
      38080
      38443
      81
      4533
    ];

    # extraCommands = ''
    #   iptables -C -A FORWARD -i docker0 -j ACCEPT
    #   iptables -C -A FORWARD -o docker0 -j ACCEPT
    # '';
  };

  # Docker Engine
  virtualisation.docker.enable = true;

  # OCI Containers (Nginx Proxy Manager)
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
