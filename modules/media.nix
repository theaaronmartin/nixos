{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    jellyfin-ffmpeg
    nvtopPackages.full
  ];

  # CRITICAL: Hardware acceleration overrides for Jellyfin
  systemd.services.jellyfin.serviceConfig = {
    DeviceAllow = lib.mkForce [
      "char-drm rw"
      "char-nvidia-frontend rw"
      "char-nvidia-uvm rw"
      "char-nvidiactl rw"
      "char-nvidia-modeset rw"
      "/dev/dri/renderD128 rw"
    ];
    PrivateDevices = lib.mkForce false;
    BindReadOnlyPaths = [ "/run/opengl-driver" ];
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
  };
  services.sabnzbd = {
    enable = true;
    openFirewall = true;
    group = "media";
  };

  services.navidrome = {
    enable = true;
    group = "media";
    openFirewall = true;
    settings = {
      Address = "0.0.0.0";
      MusicFolder = "/mnt/media/Music";
      ScanSchedule = "@every 6h";
      TranscodingCacheSize = "1GB";
      LastFM.Enabled = true;
    };
  };

  # Env file for Navidrome secrets
  systemd.services.navidrome.serviceConfig.EnvironmentFile = "/var/lib/navidrome/navidrome.env";

  services.audiobookshelf = {
    enable = true;
    host = "0.0.0.0";
    port = 8000;
  };

  systemd.services.audiobookshelf.serviceConfig = {
    Group = lib.mkForce "media";
    UMask = "0002";
    ReadWritePaths = [
      "/mnt/media/Audio\\ Books"
      "/mnt/media/Downloads/complete"
    ];
    ProtectSystem = lib.mkForce "soft";
    ProtectHome = lib.mkForce false;
  };

  networking.firewall.allowedTCPPorts = [ 8000 ];

  # Group permissions and Arr stack write paths
  users.groups.media = {
    gid = lib.mkForce 989;
    members = [
      "plague"
      "jellyfin"
      "sabnzbd"
      "radarr"
      "sonarr"
      "navidrome"
      "audiobookshelf"
    ];
  };

  systemd.services.radarr.serviceConfig = {
    Group = lib.mkForce "media";
    ReadWritePaths = [
      "/mnt/media/Movies"
      "/mnt/media/Downloads/complete"
    ];
    ProtectSystem = lib.mkForce "soft";
    ProtectHome = lib.mkForce false;
  };

  systemd.services.sonarr.serviceConfig = {
    Group = lib.mkForce "media";
    ReadWritePaths = [
      "/mnt/media/Shows"
      "/mnt/media/Downloads/complete"
    ];
    ProtectSystem = lib.mkForce "soft";
    ProtectHome = lib.mkForce false;
  };

  systemd.services.sabnzbd = {
    serviceConfig = {
      Group = lib.mkForce "media";
      # UMask 0002: files get 664 (rw-rw-r--), dirs get 775 (rwxrwxr-x)
      UMask = "0002";
    };
  };

  systemd.tmpfiles.rules = [
    "d /mnt/media_01/Downloads          0775 plague media -"
    "d /mnt/media_01/Downloads/complete 0775 plague media -"
    "d /mnt/media_01/Downloads/incomplete 0775 plague media -"
    "d /mnt/media_02/Downloads          0775 plague media -"
    "d /mnt/media_02/Downloads/complete 0775 plague media -"
    "d /mnt/media_02/Downloads/incomplete 0775 plague media -"
    "d /mnt/media/Audio\\ Books 0775 plague media -"
  ];

  users.users.sabnzbd.extraGroups = [ "media" ];
  users.users.jellyfin.extraGroups = [
    "media"
    "video"
    "render"
  ];
}
