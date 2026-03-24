{ config, pkgs, ... }: {

  hardware.cpu.amd.updateMicrocode = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false; 
    nvidiaSettings = true;
    nvidiaPersistenced = true;    

    # Optional: Use the 'production' or 'beta' branch if needed
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    zenmonitor
  ];

  hardware.nvidia-container-toolkit.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # This allows OpenRGB to talk to your motherboard and RAM
  hardware.i2c.enable = true;

  services.power-profiles-daemon.enable = false;

  powerManagement.cpuFreqGovernor = "performance";
}
