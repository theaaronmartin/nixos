# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.kernelParams = [ 
    "processor.max_cstate=1" 
    "rcu_nocbs=0-23" 
    "idle=nomwait" 
    "nvidia.NVreg_RegistryDwords=RMConnectToProtocol=1"
    "acpi_enforce_resources=lax"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages;

  networking.hostName = "NIXCORE"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Mount the Windows NTFS media drive
  fileSystems."/mnt/media" = {
    device = "/dev/disk/by-uuid/CE6CB71E6CB6FFEF";
    fsType = "ntfs-3g"; 
    # These options give your main user ownership, but grant read/execute 
    # access to everyone (including the Jellyfin service)
    options = [ "rw" "uid=1000" "gid=989" "umask=002" "nofail" ]; 
  };

  # Mount the Windows NTFS games drive
  fileSystems."/mnt/games" = {
    device = "/dev/disk/by-uuid/5C060DEE060DC9CA";
    fsType = "ntfs-3g"; 
    # These options give your main user ownership, but grant read/execute 
    # access to everyone (including the Jellyfin service)
    options = [ "rw" "uid=1000" "gid=989" "umask=002" "nofail" ]; 
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.jellyfin.serviceConfig = {
    PrivateDevices = lib.mkForce false;
    DeviceAllow = lib.mkForce [ "char-drm rw" "char-nvidia-frontend rw" "char-nvidia-uvm rw" ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.plague = {
    isNormalUser = true;
    description = "Plague";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "media" "docker" ];
    packages = with pkgs; [
      vim
      wget
      curl
      git
      vesktop
      bambu-studio
    ];
  };

  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?


  # Enable graphics support (required for hardware acceleration)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Highly recommended if you plan to PC game on this machine
  };

  # Load the Nvidia driver
  services.xserver.videoDrivers = [ "nvidia" ];

  # Configure the Nvidia card
  hardware.nvidia = {
    # Required for most modern desktop environments and Wayland
    modesetting.enable = true;
    
    # The RTX 3080 supports Nvidia's new open-source drivers, but for NVENC 
    # media transcoding, the proprietary drivers are still the gold standard.
    open = false; 
    
    # Installs the Nvidia Settings GUI application
    nvidiaSettings = true;
  };

  # Enable the Arr Stack
  services.radarr = {
    enable = true;
    group = "media";
  };

  services.sonarr = {
    enable = true;
    group = "media";
  };

  services.sabnzbd = {
    enable = true;
  };

  users.users.sabnzbd.extraGroups = [ "media" ];
  users.users.jellyfin.extraGroups = [ "media" "video" "render" ];

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  users.groups.media = {
    gid = lib.mkForce 989;
    members = [
      "plague"
      "jellyfin"
      "sabnzbd"
      "radarr"
      "sonarr"
      "navidrome"
    ];
  };
  # Ensure the services can write to your media folders
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

  systemd.services.sabnzbd.serviceConfig.Group = lib.mkForce "media";

  services.navidrome = {
    enable = true;
    group = "media"; # Use the group we just created
    openFirewall = true; # Opens port 4533 by default
  
    settings = {
      Address = "0.0.0.0";
      # Replace this with the actual path to your music
      MusicFolder = "/mnt/media/Music"; 
    
      # Optional: Customize the scan interval (in minutes)
      ScanSchedule = "@every 6h";
    
      # Useful for bandwidth if you're streaming on the go
      TranscodingCacheSize = "1GB";

      LastFM.Enabled = true;
    };
  };

  systemd.services.navidrome.serviceConfig.EnvironmentFile = "/var/lib/navidrome/navidrome.env";

  # Enable Docker
  virtualisation.docker.enable = true;

  # Define the Nginx Proxy Manager Container
  virtualisation.oci-containers = {
    backend = "docker";
    containers."nginx-proxy-manager" = {
      image = "jc21/nginx-proxy-manager:latest";
      ports = [
        "38080:80"     # Public HTTP
        "38443:443"   # Public HTTPS
        "81:81"     # Admin Web UI
      ];
      volumes = [
        "/var/lib/npm/data:/data"
        "/var/lib/npm/letsencrypt:/etc/letsencrypt"
      ];
      # Automatically start on boot
      autoStart = true;
    };
  };

  networking.firewall.checkReversePath = "loose";

  # Open the firewall ports
  networking.firewall.allowedTCPPorts = [ 38080 38443 81 4533 ];

  # This allows Docker containers to properly route traffic through the host firewall
  networking.firewall.extraCommands = ''
    iptables -A FORWARD -i docker0 -j ACCEPT
    iptables -A FORWARD -o docker0 -j ACCEPT
  '';

  # 1. Enable the OpenRGB service and udev rules
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins;
  };

  boot.extraModprobeConfig = "";

  boot.kernelModules = [ "i2c-dev" "i2c-piix4" "ee1004" ];
  hardware.i2c.enable = true;
  users.groups.i2c.members = [ "plague" ];

  # Automated fix for HyperX RAM detection in OpenRGB
  # This breaks the kernel lock (ee1004) before the OpenRGB server starts
  systemd.services.openrgb-ram-fix = {
    description = "Unbind RAM from ee1004 driver for OpenRGB";
    before = [ "openrgb.service" ]; 
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeScript "unbind-ram" ''
        #!${pkgs.bash}/bin/bash
        # Target the four slots on SMBus port 0 (addresses 50-53)
        echo "0-0050" > /sys/bus/i2c/drivers/ee1004/unbind || true
        echo "0-0051" > /sys/bus/i2c/drivers/ee1004/unbind || true
        echo "0-0052" > /sys/bus/i2c/drivers/ee1004/unbind || true
        echo "0-0053" > /sys/bus/i2c/drivers/ee1004/unbind || true
      '';
    };
  };

  # Force the main service to wait for the fix to finish
  systemd.services.openrgb.after = [ "openrgb-ram-fix.service" ];

}
