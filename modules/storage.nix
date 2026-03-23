{ config, pkgs, ... }: {
  # Support for NTFS
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/CE6CB71E6CB6FFEF";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=989" "umask=002" "nofail" ];
  };

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/5C060DEE060DC9CA";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=989" "umask=002" "nofail" ];
  };

  services.udisks2.enable = true;
}
