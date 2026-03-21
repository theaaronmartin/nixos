{ config, pkgs, lib, ... }: {
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
    PrivateDevices = lib.mkForce false;
    DeviceAllow = lib.mkForce [ "char-drm rw" "char-nvidia-frontend rw" "char-nvidia-uvm rw" ];
  };

  services.radarr = { enable = true; group = "media"; };
  services.sonarr = { enable = true; group = "media"; };
  services.sabnzbd.enable = true;

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

  # Group permissions and Arr stack write paths
  users.groups.media = {
    gid = lib.mkForce 989;
    members = [ "plague" "jellyfin" "sabnzbd" "radarr" "sonarr" "navidrome" ];
  };

  systemd.services.radarr.serviceConfig = {
    Group = lib.mkForce "media";
    ReadWritePaths = [ "/mnt/media/Movies" "/mnt/media/Downloads/complete" ];
    ProtectSystem = lib.mkForce "soft";
    ProtectHome = lib.mkForce false;
  };

  systemd.services.sonarr.serviceConfig = {
    Group = lib.mkForce "media";
    ReadWritePaths = [ "/mnt/media/Shows" "/mnt/media/Downloads/complete" ];
    ProtectSystem = lib.mkForce "soft";
    ProtectHome = lib.mkForce false;
  };

  systemd.services.sabnzbd.serviceConfig.Group = lib.mkForce "media";
  
  users.users.sabnzbd.extraGroups = [ "media" ];
  users.users.jellyfin.extraGroups = [ "media" "video" "render" ];
}
