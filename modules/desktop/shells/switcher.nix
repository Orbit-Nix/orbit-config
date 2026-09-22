{ config, pkgs, lib, ... }:

let
  orbitAutostart = pkgs.writeShellScriptBin "orbit-shell-autostart" ''
    set -e
    if command -v orbit >/dev/null 2>&1; then
      exec orbit shell autostart
    else
      STATE_FILE="''${XDG_STATE_HOME:-$HOME/.local/state}/orbitos/active_shell"
      CURRENT="end4-pC"
      if [ -f "$STATE_FILE" ]; then
        CURRENT=$(cat "$STATE_FILE" | tr -d '[:space:]')
      fi
      export qsConfig="$CURRENT"
      case "$CURRENT" in
        end4-pC|ii) exec qs -c end4-pC ;;
        midnight)   (command -v caelestia-shell >/dev/null 2>&1 && exec caelestia-shell) || exec qs -c midnight ;;
        dms)        (command -v dms >/dev/null 2>&1 && exec dms run) || exec qs -c dms ;;
        none)       exit 0 ;;
        *)          exec qs -c end4-pC ;;
      esac
    fi
  '';
in
{
  home.packages = [
    orbitAutostart
  ];
}
