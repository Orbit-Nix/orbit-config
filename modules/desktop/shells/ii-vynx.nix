{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.orbitos.shells.ii-vynx;
  isCurrentShell = config.orbitos.desktop.shell == "ii-vynx";
in
{
  options.orbitos.shells.ii-vynx = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the ii-vynx Shell (Illogical Impulse fork by vaguesyntax).";
    };
  };

  config = lib.mkIf (cfg.enable || isCurrentShell) {
    programs.illogical-impulse.enable = lib.mkDefault true;

    xdg.configFile."quickshell/ii-vynx".source = pkgs.runCommand "quickshell-ii-vynx" { } ''
      cp -r "${inputs.ii-vynx}" "$out"
      chmod -R u+w "$out"

      # Dynamic Material Cursor integration
      if [ -f "$out/scripts/colors/applycolor.sh" ]; then
        cat << 'EOF' >> "$out/scripts/colors/applycolor.sh"

# Dynamic Material Cursor integration
if [ -x "$HOME/.config/cursor/cursor-material-set-color.sh" ]; then
  "$HOME/.config/cursor/cursor-material-set-color.sh" &
fi
EOF
      fi
    '';

    home.sessionVariables = lib.mkIf isCurrentShell {
      qsConfig = "ii-vynx";
    };
  };
}
