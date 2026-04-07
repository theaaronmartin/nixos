{ config, pkgs, ... }:
{

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
    nvidiaPersistenced = false;

    # Optional: Use the 'production' or 'beta' branch if needed
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  environment.systemPackages = with pkgs; [
    zenmonitor
  ];

  hardware.nvidia-container-toolkit.enable = true;

  services.power-profiles-daemon.enable = false;

  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="244f", ATTRS{idProduct}=="0101", MODE="0660", GROUP="audio"
  '';

  powerManagement.cpuFreqGovernor = "performance";

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    pipewire
    alsa-lib
    curl
    gnutls
    zlib
    libGL
    freetype
    glib
    xorg.libX11
    xorg.libXext
    xorg.libSM
    xorg.libICE
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXi
  ];

}
