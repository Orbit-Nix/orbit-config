{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.orbitos.shells.end4-pC;
  isCurrentShell = config.orbitos.desktop.shell == "end4-pC";
in
{
  options.orbitos.shells.end4-pC = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
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
        ${pkgs.python3}/bin/python3 -c "
import pathlib
path = pathlib.Path('$out/scripts/colors/generate_colors_material.py')
content = path.read_text()
content = content.replace(\"material_colors['primary_paletteKeyColor']\", \"material_colors.get('primary_paletteKeyColor', material_colors.get('primary', '#c7bfff'))\")
path.write_text(content)
"
      fi

      # Fix thumbgen-venv.sh virtualenv activation errors
      if [ -f "$out/scripts/thumbnails/thumbgen-venv.sh" ]; then
        ${pkgs.python3}/bin/python3 -c "
import pathlib
path = pathlib.Path('$out/scripts/thumbnails/thumbgen-venv.sh')
content = path.read_text()
content = content.replace('source \$(eval echo \$ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate', '[ -f \"\$(eval echo \$ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate\" ] && source \"\$(eval echo \$ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate\" || true')
content = content.replace('deactivate', 'type deactivate &>/dev/null && deactivate || true')
path.write_text(content)
"
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
