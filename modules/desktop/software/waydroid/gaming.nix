{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.waydroid.gaming;
in {
  options.mySystem.waydroid.gaming = {
    enable = lib.mkEnableOption "Gaming-optimized Waydroid setup with tools and wrappers";
  };

  config = lib.mkIf cfg.enable {
    # Gaming requires the minimal Waydroid engine naturally
    mySystem.waydroid.minimal.enable = true;

    # Waydroid needs network bridge for some games and store access
    networking.firewall.trustedInterfaces = [ "waydroid0" ];

    environment.systemPackages = with pkgs; [
      # The community script which downloads libHoudini and LibNDK for ARM translation!
      waydroid-script
      
      # Isolated Wayland compositor to wrap games flawlessly outside the desktop environment
      cage
      
      # Android CLI tools for sideloading APKS
      android-tools

      # Our dedicated Android Gaming launcher script
      (pkgs.writeShellScriptBin "play-android" ''
        #!/usr/bin/env bash
        set -e
        if [ -z "$1" ]; then
          echo "[!] Usage: play-android <package.name>"
          echo "    Example: play-android com.miHoYo.GenshinImpact"
          exit 1
        fi
        
        echo "[+] Booting Waydroid engine for gaming environment..."
        waydroid session start &
        
        echo "[+] Launching $1 in an isolated Cage Wayland session..."
        # Waydroid games run vastly better bound directly to an independent compositor
        cage -s -- waydroid app launch "$1"
      '')
    ];
  };
}
