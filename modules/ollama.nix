{ pkgs-unstable, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama;
    acceleration = "cuda";
  };

  # Optional: Add firewall rule if you want remote access (default is localhost only)
  # networking.firewall.allowedTCPPorts = [ 11434 ];
}