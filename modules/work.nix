{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    teams-for-linux
    zoom-us # added 2026-09-01: installed and in use on the Windows laptop
  ];
}
