{ pkgs-unstable, ... }:

{
  # The pi coding agent, which consumes the Ollama server below through
  # ~/.pi/agent/models.json. It lives here rather than in dev.nix because
  # dev.nix is imported by both hosts and pi's local models only exist where
  # Ollama runs. Moved 2026-09-04.
  #
  # `pi` has no attribute in nixpkgs 25.11 -- it only exists on unstable
  # (pi-coding-agent 0.84.2), so a bare `pi-coding-agent` fails eval with
  # `undefined variable`. Substitutes prebuilt; no source build.
  environment.systemPackages = [ pkgs-unstable.pi-coding-agent ];

  services.ollama = {
    enable = true;
    acceleration = "cuda"; # Automatically configures CUDA runtime & drivers
    package = pkgs-unstable.ollama-cuda;

    # Optional optimizations for VRAM and throughput
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      # Deliberately q4_0, not q8_0. q8_0 roughly doubles KV-cache size, which
      # on this 10 GB card pushed qwen3-14b-iq4xs off the GPU at every useful
      # context (it spilled even at 6144). Measured 2026-09-04: 29.9 tok/s
      # spilled vs 75.0 tok/s fully resident, for no accuracy gain we could
      # detect. On 10 GB, spend VRAM on weights rather than KV precision.
      OLLAMA_KV_CACHE_TYPE = "q4_0";

      # Ollama otherwise serves 4096 tokens regardless of what a model
      # advertises, which is too small for agentic use (pi). Not visible in
      # `ollama show` - only the CONTEXT column of `ollama ps` reveals it.
      # Per-model `num_ctx` tags override this; this is the floor for anything
      # untuned.
      OLLAMA_CONTEXT_LENGTH = "12288";

      # Default is 5m, which makes an idle agent pay a multi-GB reload.
      OLLAMA_KEEP_ALIVE = "30m";
    };

    # Listen on localhost default port 11434
    host = "127.0.0.1";
    port = 11434;
  };

  # Required when using CUDA acceleration
  nixpkgs.config.allowUnfree = true;
}
