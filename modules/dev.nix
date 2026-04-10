{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    gcc
    lua-language-server
    nil
    typescript-language-server
    yaml-language-server
    biome
    clang-tools
    nodejs_20
    opencode
  ];
}
