{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.waydroid.minimal;
in {
  options.mySystem.waydroid.minimal = {
    enable = lib.mkEnableOption "Minimal working Waydroid environment for Android apps";
  };

  config = lib.mkIf cfg.enable {
    # NixOS built-in Waydroid configuration setup
    virtualisation.waydroid.enable = true;

    environment.systemPackages = with pkgs; [
      waydroid
      wl-clipboard # Useful for sharing clipboard with Waydroid clipboard instance
    ];
  };
}
