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

    imports = [ inputs.midnight-shell.homeManagerModules.default ];

  config = lib.mkIf (cfg.enable || isCurrentShell) {
    # Build and deploy Midnight Shell Quickshell configuration
        programs.caelestia = {
      enable = true;
      package = inputs.midnight-shell.packages.${pkgs.system}.default.overrideAttrs (old: {
        prePatch = (old.prePatch or "") + ''
          for script in scripts/colors/applycolor.sh scripts/applycolor.sh scripts/color.sh; do
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
      });
      systemd.enable = false;
    };

    # Also make available as midnight-shell and caelestia for standard CLI aliases
    
    

    home.sessionVariables = lib.mkIf isCurrentShell {
      qsConfig = "midnight";
    };
  };
}
