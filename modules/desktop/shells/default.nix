{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # Upstream shell modules from flake inputs (guarded if inputs are available)
    (lib.mkIf (inputs ? illogical-flake) inputs.illogical-flake.homeManagerModules.default)
    (lib.mkIf (inputs ? dms) inputs.dms.homeModules.dank-material-shell)

    # Shell submodules
    ./end4-pC.nix
    ./midnight.nix
    ./dms.nix
    ./switcher.nix
  ];

  options.orbitos.desktop = {
    shell = lib.mkOption {
      type = lib.types.enum [ "end4-pC" "midnight" "dms" "none" ];
      default = "end4-pC";
      example = "midnight";
      description = ''
        The active desktop shell suite for OrbitOS.
        Choices:
          - "end4-pC"   : Illogical Impulse Material 3 Quickshell desktop
          - "midnight"  : Midnight Shell (dim-ghub/midnight-shell) Caelestia fork
          - "dms"       : DankMaterialShell (AvengeMedia/DankMaterialShell)
          - "none"      : No desktop shell bar/widgets
      '';
    };
  };
}
