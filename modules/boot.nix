{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # memtest86 moved to hosts/NIXCORE 2026-09-01 - it was added for the 2026-08-14
  # freeze diagnosis and is NIXCORE-specific. It also consumes ESP space, which
  # is scarce on SHELL.
}
