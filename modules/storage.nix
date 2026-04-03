{ config, pkgs, ... }: {
  # Support for NTFS
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/CE6CB71E6CB6FFEF";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=989" "umask=002" "nofail" ];
  };

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-label/games";
    fsType = "ext4";
    options = [ "defaults" "noatime" "discard" "nofail" ];
  };

  fileSystems."/mnt/media_02" = {
    device = "/dev/disk/by-uuid/7ba88822-9946-4d59-aa13-92bfef10744f";
    fsType = "ext4";
    options = [ "defaults" "noatime" "discard" "nofail" ];
  };

  services.udisks2.enable = true;
  services.udisks2.mountOnMedia = true;
}
