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
    { self
    , nixpkgs
    , nixpkgs-unstable
    , ...
    }@inputs:
    let
      hostPlatform = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${hostPlatform};

      pkgs-unstable = import nixpkgs-unstable {
        system = hostPlatform;
        config.allowUnfree = true;
        config.cudaSupport = true;
      };

      makeHostConfig =
        hostModule:
        nixpkgs.lib.nixosSystem {
          system = hostPlatform;
          specialArgs = { inherit inputs pkgs-unstable; };
          modules = [
            hostModule
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
              home-manager.users.plague = import ./home.nix;
            }
          ];
        };
    in
    {
      formatter.${hostPlatform} = pkgs.nixpkgs-fmt;
      nixosConfigurations.NIXCORE = makeHostConfig ./hosts/NIXCORE;
      nixosConfigurations.SHELL = makeHostConfig ./hosts/SHELL;
    };
}
