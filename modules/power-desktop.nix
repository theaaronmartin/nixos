# Desktop power policy. Split out of hardware.nix (2026-09-01) so it stops
# following SHELL, where pinning the governor to "performance" would cook the
# battery. NIXCORE only.
{
  services.power-profiles-daemon.enable = false;
  powerManagement.cpuFreqGovernor = "performance";
}
