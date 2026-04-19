{
  description = "Plague's NixOS configurations: NIXCORE (desktop) and SHELL (laptop)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }@inputs:
    let
      hostPlatform = "x86_64-linux";

      pkgs-unstable = import nixpkgs-unstable {
        system = hostPlatform;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };
    in
    {
      nixosConfigurations.NIXCORE = nixpkgs.lib.nixosSystem {
        system = hostPlatform;

        specialArgs = { inherit inputs pkgs-unstable; };

        modules = [
          ./hosts/NIXCORE
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              hostName = "NIXCORE";
            };
            home-manager.users.plague = import ./home.nix;
          }
        ];
      };

      nixosConfigurations.SHELL = nixpkgs.lib.nixosSystem {
        system = hostPlatform;

        specialArgs = { inherit inputs pkgs-unstable; };

        modules = [
          ./hosts/SHELL
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs;
              hostName = "SHELL";
            };
            home-manager.users.plague = import ./home.nix;
          }
        ];
      };
    };
}
