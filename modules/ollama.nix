{ pkgs-unstable, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama-cuda;
    acceleration = "cuda";
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      # Compresses the memory used by the context window
      # 'q8_0' is high quality, 'q4_0' is maximum space-saving
      OLLAMA_KV_CACHE_TYPE = "q4_0";
    };
  };

  # Optional: Add firewall rule if you want remote access (default is localhost only)
  # networking.firewall.allowedTCPPorts = [ 11434 ];
}

