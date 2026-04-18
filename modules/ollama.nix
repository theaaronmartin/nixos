{ pkgs-unstable, ... }:

# {
#   services.ollama = {
#     enable = true;
#     package = pkgs-unstable.ollama-cuda;
#     acceleration = "cuda";
#
#     environmentVariables = {
#       OLLAMA_FLASH_ATTENTION = "1";
#       OLLAMA_KV_CACHE_TYPE = "q4_0";
#     };
#   };
# }

{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    acceleration = "cuda"; # Or "rocm" for AMD

    # Manually bump the package to support Gemma 4 architectures
    package = (
      pkgs.ollama-cuda.overrideAttrs (oldAttrs: rec {
        version = "0.20.3";

        # 1. Fetch Source
        src = pkgs.fetchFromGitHub {
          owner = "ollama";
          repo = "ollama";
          rev = "v${version}";
          hash = "sha256-o9iCqdOfNMxfIyThQAOSSQZE2ZyBuyJWFr6wqvQo1A0=";
          fetchSubmodules = true;
        };

        # 2. Fix Tree-sitter Dependencies
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
        buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ pkgs.tree-sitter ];

        # 3. Fix the "parser.c" Path Error
        # Setting proxyVendor to true handles the submodules correctly
        # and avoids the broken relative paths in the vendor/ folder.
        proxyVendor = true;

        # IMPORTANT: Changing proxyVendor changes the hash!
        # Leave this as fakeHash once, run nix-switch, and grab the new got: hash.
        vendorHash = "sha256-Lc1Ktdqtv2VhJQssk8K1UOimeEjVNvDWePE9WkamCos=";

        # Skip checks to speed up the manual override build
        doCheck = false;
      })
    );
  };
}
