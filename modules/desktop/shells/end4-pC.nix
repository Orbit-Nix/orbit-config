{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.orbitos.shells.end4-pC;
  isCurrentShell = config.orbitos.desktop.shell == "end4-pC";
in
{
  options.orbitos.shells.end4-pC = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = isCurrentShell;
      description = "Enable the Illogical Impulse / end4-pC Shell.";
    };
  };

  config = lib.mkIf (cfg.enable || isCurrentShell) {
    # Illogical Impulse background daemon
    programs.illogical-impulse.enable = lib.mkDefault true;

    # Build and patch end4-pC Quickshell dotfiles
    xdg.configFile."quickshell/end4-pC".source = pkgs.runCommand "quickshell-end4-pC" { } ''
      cp -r "${inputs.end4-pC}" "$out"
      chmod -R u+w "$out"

      # Fix KeyError on primary_paletteKeyColor in generate_colors_material.py
      if [ -f "$out/scripts/colors/generate_colors_material.py" ]; then
        ${pkgs.gnused}/bin/sed -i "s/material_colors\\['primary_paletteKeyColor'\\]/material_colors.get('primary_paletteKeyColor', material_colors.get('primary', '#c7bfff'))/g" "$out/scripts/colors/generate_colors_material.py"
      fi

      # Fix thumbgen-venv.sh virtualenv activation errors
      if [ -f "$out/scripts/thumbnails/thumbgen-venv.sh" ]; then
        ${pkgs.gnused}/bin/sed -i 's|source $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate|[ -f "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate" ] \&\& source "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate" \\|\\| true|' "$out/scripts/thumbnails/thumbgen-venv.sh"
        ${pkgs.gnused}/bin/sed -i 's|deactivate|type deactivate \&>/dev/null \&\& deactivate \\|\\| true|' "$out/scripts/thumbnails/thumbgen-venv.sh"
      fi

      # Inject dynamic Material cursor switcher into applycolor.sh
      if [ -f "$out/scripts/colors/applycolor.sh" ]; then
        cat << 'EOF' >> "$out/scripts/colors/applycolor.sh"

# Dynamic Material Cursor integration
if [ -x "$HOME/.config/cursor/cursor-material-set-color.sh" ]; then
  "$HOME/.config/cursor/cursor-material-set-color.sh" &
fi
EOF
      fi
    '';

    # Also symlink quickshell/ii to end4-pC for backwards compatibility
    xdg.configFile."quickshell/ii".source = config.xdg.configFile."quickshell/end4-pC".source;

    home.sessionVariables = lib.mkIf isCurrentShell {
      qsConfig = "end4-pC";
    };
  };
}
