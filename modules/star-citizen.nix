{ config, pkgs, inputs, ... }:

let
  # Access the package from the nix-gaming input
  sc-pkg = inputs.nix-gaming.packages.${pkgs.system}.star-citizen;
in
{
  # 1. Kernel Tweaks (RCA: Required for EAC and memory-mapped files)
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

  # 2. System Packages
  environment.systemPackages = [
    sc-pkg
    pkgs.winetricks
  ];

  environment.sessionVariables = {
    # Force Wine to find the NVIDIA Vulkan driver
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";
    
    # Help DXVK identify your 3080
    DXVK_FILTER_DEVICE_NAME = "GeForce RTX 3080";
    
    # Prevent CUDA/NVAPI conflicts in 2026 builds
    WINE_HIDE_NVIDIA_GPU = "1";
  };

  # 3. Permissions & Logging (Aligning with GID 989)
  # We create a post-activation script to ensure the game folder 
  # stays accessible for your 'media' group tools.
  system.activationScripts.sc-permissions = {
    text = ''
      mkdir -p /home/plague/Games/star-citizen
      chown -R plague:media /home/plague/Games/star-citizen
      chmod -R 775 /home/plague/Games/star-citizen
    '';
  };
}
