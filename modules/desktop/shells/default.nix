{ config, pkgs, lib, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  # Use the already built working quickshell package to avoid broken Qt 6.12 type-traits build error in upstream quickshell
  cachedQuickshell = pkgs.runCommand "quickshell-with-qtpositioning" {
    meta.mainProgram = "quickshell";
  } ''
    mkdir -p $out/bin $out/share
    ln -s /nix/store/7xicjw342vikhgiw8whamyjw01ykbac6-quickshell-with-qtpositioning/bin/quickshell $out/bin/quickshell
    ln -s /nix/store/7xicjw342vikhgiw8whamyjw01ykbac6-quickshell-with-qtpositioning/bin/qs $out/bin/qs
    if [ -d /nix/store/7xicjw342vikhgiw8whamyjw01ykbac6-quickshell-with-qtpositioning/share ]; then
      cp -r /nix/store/7xicjw342vikhgiw8whamyjw01ykbac6-quickshell-with-qtpositioning/share/* $out/share/ || true
    fi
  '';

  illogicalInputs = inputs.illogical-flake.inputs // {
    quickshell = {
      packages.${system}.default = cachedQuickshell;
    };
  };

  illogicalModule = { config, lib, pkgs, ... }: (import (inputs.illogical-flake + "/home-module.nix")) {
    inherit config lib pkgs;
    inputs = illogicalInputs;
  };
in
{
  imports = [
    illogicalModule
    inputs.dms.homeModules.dank-material-shell
    ./end4-pC.nix
    ./ii-vynx.nix
    ./midnight.nix
    ./dms.nix
    ./noctalia.nix
    ./switcher.nix
  ];

  options.orbitos.desktop = {
    shell = lib.mkOption {
      type = lib.types.enum [
        "illogical-impulse"
        "end4-pC"
        "ii-vynx"
        "caelestia"
        "midnight"
        "dms"
        "noctalia"
        "none"
      ];
      default = "illogical-impulse";
      example = "caelestia";
      description = ''
        The active desktop shell suite for OrbitOS (Tree view):
        
        ├── Illogical Impulse (selectable parent or specific child)
        │   ├── "illogical-impulse" : Default Illogical Impulse suite
        │   ├── "end4-pC"         : Material 3 Quickshell desktop
        │   └── "ii-vynx"         : vaguesyntax ii-vynx scrolling-dots fork
        ├── Caelestia (selectable parent or specific child)
        │   ├── "caelestia"       : Default Caelestia shell
        │   └── "midnight"        : Midnight Shell (dim-ghub/midnight-shell)
        ├── DMS (selectable, no childs)
        │   └── "dms"             : DankMaterialShell
        └── Noctalia (selectable, no childs)
            └── "noctalia"        : Noctalia Shell
      '';
    };
  };
}
