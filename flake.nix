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
    # No `inputs.nixpkgs.follows` here: this flake declares no inputs at all
    # (`outputs = _: { ... }`), so a follows override for one is a reference
    # to something that does not exist. Nix reports it as an override for a
    # non-existent input and then treats the whole lock file as
    # inconsistent, re-resolving every unlocked input from scratch on each
    # operation. That silently moved nixpkgs and home-manager off their pins.
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };
    driftwm = {
      url = "github:malbiruk/driftwm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Autodesk Fusion 360 under Wine. It is not in nixpkgs; the flake ships
    # an overlay that callPackages it into the package set. Its own flake
    # pins nixpkgs to nixos-26.05, which `follows` overrides so the build
    # uses this config's nixos-unstable instead of pulling a second channel
    # into the store. The overlay only wraps `prev.callPackage`, so nothing
    # else in the flake is sensitive to the pin.
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

    # Jovian. Steam Deck's NixOS layer: their vendored gamescope, the gaming
    # mode session, Decky Loader and the Proton GE build. It also carries the
    # overlay Decky Loader is packaged in, because decky-loader is not in
    # nixpkgs. `development` is the branch that tracks nixpkgs-unstable.
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS/development";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, driftwm, nix-flatpak, disko, jovian, fusion-nix, ... }@inputs:
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

    # Jovian's NixOS module only defines options, so importing it changes
    # nothing until a host turns one on. The overlay is separate and always
    # active: it is what puts gamescope and inputplumber in the package set,
    # and it is where decky-loader comes from, since that package does not
    # exist in nixpkgs.
    #
    # The second overlay undoes one thing the first does. Jovian re-applies two
    # MangoHud backports on top of nixpkgs' mangohud, and nixpkgs has since
    # taken the first one in itself, so the second application fails the build.
    # Dropping the backports leaves the nixpkgs mangohud, which is what runs
    # here anyway.
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

    # Fusion 360 comes from an overlay, not from nixpkgs, so the package has
    # to be in the set before modules can name it. That makes this a
    # separate concern from whether any host actually installs the app, so
    # the overlay goes on every graphical host and
    # `mySystem.apps.cad` decides who gets the binary. Defined as its own
    # module list rather than folded into jovianModules because it is
    # unrelated to gaming and would only muddy that list's comment.
    fusionModules = [
      { nixpkgs.overlays = [ fusion-nix.overlays.default ]; }
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
        ++ fusionModules;
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
        ++ fusionModules;
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
        ++ fusionModules;
      };
    };
  };
}
