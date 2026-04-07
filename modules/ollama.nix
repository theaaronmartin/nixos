{ config, pkgs, lib, pkgs-unstable, ... }:

{
  # Enable Ollama service
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama; # Use unstable for newer version
  };

  # Add Ollama to user packages for CLI access
  home-manager.users.plague = {
    home.packages = with pkgs-unstable; [
      ollama
    ];
  };

  # Optional: Add firewall rule if you want remote access (default is localhost only)
  # networking.firewall.allowedTCPPorts = [ 11434 ];
}