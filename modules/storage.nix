{ config, pkgs, ... }:
{

  fileSystems."/mnt/media_01" = {
    device = "/dev/disk/by-uuid/7e015eda-3f74-409e-9b62-d17cbd237e29";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
      "discard"
      "nofail"
    ];
  };

  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-label/games";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
      "discard"
      "nofail"
    ];
  };

  fileSystems."/mnt/media_02" = {
    device = "/dev/disk/by-uuid/7ba88822-9946-4d59-aa13-92bfef10744f";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
      "discard"
      "nofail"
    ];
  };

  # MergerFS configuration - combine media_01 and media_02 into /mnt/media
  fileSystems."/mnt/media" = {
    device = "/mnt/media_01:/mnt/media_02";
    fsType = "fuse.mergerfs";
    options = [
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=epmfs"
      "minfreespace=10G"
      "fsname=mergerfs_media"
    ];
  };

  # Enable FUSE and add mergerfs package
  boot.supportedFilesystems = [
    "fuse"
    "ext4"
    "ntfs"
  ];
  environment.systemPackages = with pkgs; [ mergerfs ];

  # Configure fuse to allow non-root users
  environment.etc."fuse.conf".text = ''
    user_allow_other
    mount_max = 1000
  '';

  services.udisks2.enable = true;
  services.udisks2.mountOnMedia = true;
}
