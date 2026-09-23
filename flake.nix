{
  description = "OrbitOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Orbit CLI
    orbit-cli = {
      url = "github:Orbit-Nix/orbit-cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Custom Software
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    driftwm = {
      url = "github:malbiruk/driftwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative Partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # illogical-impulse & end4-pC Shell
    illogical-flake = {
      url = "github:soymou/illogical-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    end4-pC = {
      url = "github:pctrade/end4-pC";
      flake = false;
    };

    # Midnight Shell
    midnight-shell = {
      url = "github:dim-ghub/midnight-shell";
    };

    # DankMaterialShell (DMS) & Plugins
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, driftwm, nix-flatpak, disko, ... }@inputs:
  let
    system = "x86_64-linux";
    username = "m_uvex";
    pkgs = nixpkgs.legacyPackages.${system};
    specialArgs = { inherit inputs username; };

    homeManagerModule = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.users.m_uvex = ./users/m_uvex/home.nix;
    };
  in {

    nixosConfigurations = {
      #=========================================#
      #                 Orion                   #
      #           Laptop: HP 15, NixOS          #
      #=========================================#
      lt-hp15-nix = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          driftwm.nixosModules.default
          home-manager.nixosModules.home-manager
          homeManagerModule
          ./hosts/lt-hp15-nix/default.nix
        ];
      };

      #=========================================#
      #               Andromeda                 #
      #         PC: Zoko Smile, NixOS           #
      #=========================================#
      pc-smile-nix = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          driftwm.nixosModules.default
          home-manager.nixosModules.home-manager
          homeManagerModule
          ./hosts/pc-smile-nix/default.nix
        ];
      };

      #=========================================#
      #                 Lunar                   #
      #   Server: Lenovo AIO C40-30, NixOS      #
      #=========================================#
      srv-c4030-nix = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          disko.nixosModules.disko
          ./hosts/srv-c4030-nix/default.nix
        ];
      };

      #=========================================#
      #                Voyager                  #
      #   Portable: General purpose, NixOS      #
      #=========================================#
      prt-roam-nix = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = [
          disko.nixosModules.disko
          nix-flatpak.nixosModules.nix-flatpak
          driftwm.nixosModules.default
          home-manager.nixosModules.home-manager
          homeManagerModule
          ./hosts/prt-roam-nix/default.nix
        ];
      };
    };
  };
}
