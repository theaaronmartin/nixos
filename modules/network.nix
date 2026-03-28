{ config, pkgs, ... }: {

  networking.networkmanager.enable = true;

  networking.hosts = {
    "127.0.0.1" = [ 
      "production-request.native-instruments.com" 
      "cloud-api.native-instruments.com" 
      "modules-cdn.eac-prod.on.epicgames.com"
    ];
  };

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    allowedTCPPorts = [ 38080 38443 81 4533 ];
    
    extraCommands = ''
      iptables -A FORWARD -i docker0 -j ACCEPT
      iptables -A FORWARD -o docker0 -j ACCEPT
    '';
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
