{ pkgs-unstable, ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "cuda"; # Automatically configures CUDA runtime & drivers
    package = pkgs-unstable.ollama-cuda;

    # Optional optimizations for VRAM and throughput
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q4_0";
    };

    # Listen on localhost default port 11434
    host = "127.0.0.1";
    port = 11434;
  };

  # Required when using CUDA acceleration
  nixpkgs.config.allowUnfree = true;
}
