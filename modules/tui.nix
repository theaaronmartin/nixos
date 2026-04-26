{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    bottom
    ncdu
    cmatrix
    fastfetch
    basalt
  ];
}
