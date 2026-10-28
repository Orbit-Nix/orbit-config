{ config, pkgs, lib, ... }:

let
  orbitAutostart = pkgs.writeShellScriptBin "orbit-shell-autostart" ''
    set -e
    if command -v orbit >/dev/null 2>&1; then
      exec orbit shell autostart
    else
      STATE_FILE="''${XDG_STATE_HOME:-$HOME/.local/state}/orbitos/active_shell"
      CURRENT="illogical-impulse"
      if [ -f "$STATE_FILE" ]; then
        CURRENT=$(cat "$STATE_FILE" | tr -d '[:space:]')
      fi
      export qsConfig="$CURRENT"
      case "$CURRENT" in
        illogical-impulse|end4-pC) exec qs -c end4-pC ;;
        ii-vynx)                   exec qs -c ii-vynx ;;
        caelestia|midnight)        (command -v caelestia-shell >/dev/null 2>&1 && exec caelestia-shell) || exec qs -c midnight ;;
        dms)                       (command -v dms >/dev/null 2>&1 && exec dms run) || exec qs -c dms ;;
        noctalia)                  (command -v noctalia >/dev/null 2>&1 && exec noctalia) || exec qs -c noctalia ;;
        none)                      exit 0 ;;
        *)                         exec qs -c end4-pC ;;
      esac
    fi
  '';
in
{
  home.packages = [
    orbitAutostart
  ];
}
