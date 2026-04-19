{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    gcc
    lua-language-server
    nil
    nixfmt-rfc-style
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
  ];
}
