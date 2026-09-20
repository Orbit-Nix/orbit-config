{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.orbitos.shells.midnight;
  isCurrentShell = config.orbitos.desktop.shell == "midnight";
in
{
  options.orbitos.shells.midnight = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the Midnight Shell.";
    };
  };

  config = lib.mkIf (cfg.enable || isCurrentShell) {
    # Build and deploy Midnight Shell Quickshell configuration
    xdg.configFile."quickshell/midnight".source = pkgs.runCommand "quickshell-midnight" { } ''
      cp -r "${inputs.midnight-shell}" "$out"
      chmod -R u+w "$out"

      # Dynamic Material Cursor integration hook
      for script in "$out/scripts/colors/applycolor.sh" "$out/scripts/applycolor.sh" "$out/scripts/color.sh"; do
        if [ -f "$script" ]; then
          cat << 'EOF' >> "$script"

# Dynamic Material Cursor integration
if [ -x "$HOME/.config/cursor/cursor-material-set-color.sh" ]; then
  "$HOME/.config/cursor/cursor-material-set-color.sh" &
fi
EOF
        fi
      done
    '';

    # Also make available as midnight-shell and caelestia for standard CLI aliases
    xdg.configFile."quickshell/midnight-shell".source = config.xdg.configFile."quickshell/midnight".source;
    xdg.configFile."quickshell/caelestia".source = config.xdg.configFile."quickshell/midnight".source;

    home.sessionVariables = lib.mkIf isCurrentShell {
      qsConfig = "midnight";
    };
  };
}
