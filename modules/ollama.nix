{ config, pkgs, lib, pkgs-unstable, ... }:

{
  # Enable Ollama service
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama; # Use unstable for newer version
    # acceleration = "cuda"; # Removed - let Ollama auto-detect GPU
  };

  # Add CUDA to system packages for GPU acceleration
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
  ];

  # Add environment variables for CUDA
  environment.sessionVariables = {
    CUDA_PATH = "${pkgs.cudaPackages.cudatoolkit}";
    LD_LIBRARY_PATH = "${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudatoolkit.lib}/lib";
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