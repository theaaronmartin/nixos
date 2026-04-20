{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    gcc
    lua-language-server
    nil
    nixpkgs-fmt
    typescript-language-server
    yaml-language-server
    biome
    clang-tools
    nodejs_20
    opencode
    cmake
    gnumake
    pkg-config
    curl.dev
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy
  ];
}
