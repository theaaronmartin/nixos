{ pkgs, inputs, ... }: {

  environment.systemPackages = [
    # This pulls the specialized runner from the flake
    inputs.nix-citizen.packages.${pkgs.system}.star-citizen
  ];

  # Mandatory for Alpha 4.0 to prevent memory crashes
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };
}
