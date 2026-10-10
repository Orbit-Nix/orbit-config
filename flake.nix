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
    # ArtCraft Suite (Community Flake)
    artcraft = {
      url = "github:Hy4ri/artcraft-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # OpenDesign
    opendesign = {
      url = "github:m-uvex/opendesign-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    driftwm = {
      url = "github:malbiruk/driftwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AutoDesk Fusion360
    fusion-nix = {
      url = "github:bluer222/fusion-nix";
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

    # Jovian (Steam theming)
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS/development";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, opendesign, home-manager, driftwm, nix-flatpak, disko, jovian, fusion-nix, artcraft, ... }@inputs:
  let
    system = "x86_64-linux";
    username = "m_uvex";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
    specialArgs = { inherit inputs username; };

    homeManagerModule = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "backup";
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.users.m_uvex = ./users/m_uvex/home.nix;
    };

    jovianModules = [
      jovian.nixosModules.default
      {
        nixpkgs.overlays = [
          jovian.overlays.default
          (
            final: prev: {
              # prev, not final: referring to final.mangohud here would be
              # this same attribute and the overlay would never resolve.
              mangohud = prev.mangohud.overrideAttrs (old: {
                patches = builtins.filter (
                  p: !lib.hasInfix "flightlessmango/MangoHud/commit" (p.url or "")
                ) (old.patches or [ ]);
              });
            }
          )
        ];
      }
    ];

    fusionModules = [
      { nixpkgs.overlays = [ fusion-nix.overlays.default ]; }
    ];
    
    artcraftModules = [
      { nixpkgs.overlays = [ artcraft.overlays.default ]; }
    ];
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
        ]
        ++ jovianModules
        ++ fusionModules
        ++ artcraftModules;
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
        ]
        ++ jovianModules
        ++ fusionModules
        ++ artcraftModules;
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
        ]
        ++ jovianModules
        ++ fusionModules
        ++ artcraftModules;
      };
    };
  };
}
