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

  services.power-profiles-daemon.enable = false;

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="244f", ATTRS{idProduct}=="0101", MODE="0666", GROUP="audio"
  '';

  powerManagement.cpuFreqGovernor = "performance";
}
