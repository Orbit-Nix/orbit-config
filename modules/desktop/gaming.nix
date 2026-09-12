{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.gaming;

  # Wrapper scripts for Flatpak apps
  modrinthWrapper = pkgs.writeShellScriptBin "modrinth" ''
    exec flatpak run com.modrinth.ModrinthApp "$@"
  '';
  soberWrapper = pkgs.writeShellScriptBin "sober" ''
    exec flatpak run org.vinegarhq.Sober "$@"
  '';

  #==================================#
  #      GAMING APP DICTIONARIES     #
  #==================================#
  launcherMap = {
    "steam"        = pkgs.steam;
    "heroic"       = pkgs.heroic;
    "hydra"        = pkgs.hydralauncher;
    "lutris"       = pkgs.lutris;
    "bottles"      = pkgs.bottles;
    "itch"         = pkgs.itch;
    "sober"        = soberWrapper;
    "roblox"       = soberWrapper; # Alias for Sober
  };

  minecraftMap = {
    "minecraft"    = pkgs.minecraft; # NOT RECOMMENDED! BROKEN!
    "prism"        = pkgs.prismlauncher;
    "lunar"        = pkgs.lunar-client;
    "bedrock"      = pkgs.mcpelauncher-ui-qt;
    "modrinth"     = modrinthWrapper;
    "atlauncher"   = pkgs.atlauncher;
    "gdlauncher"   = pkgs.gdlauncher-carbon;
    "badlion"      = pkgs.badlion-client;
  };

  emulatorMap = {
    "pcsx2"        = pkgs.pcsx2;
    "rpcs3"        = pkgs.rpcs3;
    "ryujinx"      = pkgs.ryujinx;
    "dolphin"      = pkgs.dolphin-emu;
    "retroarch"    = pkgs.retroarch;
    "ppsspp"       = pkgs.ppsspp;
  };

  toolMap = {
    "mangohud"     = pkgs.mangohud;
    "dualsensectl" = pkgs.dualsensectl;
    "protonup-qt"  = pkgs.protonup-qt;
    "protontricks" = pkgs.protontricks;
    "goverlay"     = pkgs.goverlay;
  };

  #==================================#
  #  AUTOMATIC RESOLUTION FUNCTION   #
  #         ( DONT TOUCH! )          #
  #==================================#
  resolveApps = mapObj: selectedKeys:
    lib.concatMap (key:
      let val = mapObj.${key}; in
      if builtins.isList val then val else [ val ]
    ) selectedKeys;

  # Check launcher selections
  hasSteam  = builtins.elem "steam" cfg.launchers;
  hasSober  = builtins.elem "sober" cfg.launchers || builtins.elem "roblox" cfg.launchers;
  hasModrinth = builtins.elem "modrinth" cfg.minecraft;

in
{
  options.mySystem.gaming = {
    enable = lib.mkEnableOption "Gaming launchers, drivers, and tools";

    # --- PERFORMANCE & SYSTEM INTEGRATIONS ---
    optimizations = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable GameMode and GameScope.";
    };

    controllers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Xbox and DualSense controller drivers & udev rules.";
    };

    # --- LAUNCHERS & STORES ---
    launchers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames launcherMap));
      default = [ "steam" "heroic" ];
      description = "List of game launchers and stores to install.";
    };

    # --- MINECRAFT LAUNCHERS ---
    minecraft = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames minecraftMap));
      default = [ "prism" "lunar" "bedrock" ];
      description = "List of Minecraft clients and launchers to install.";
    };

    # --- EMULATORS ---
    emulators = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames emulatorMap));
      default = [ ];
      description = "List of console emulators to install.";
    };

    # --- TOOLS & OVERLAYS ---
    tools = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames toolMap));
      default = [ "mangohud" "dualsensectl" ];
      description = "List of gaming utilities and driver managers.";
    };
  };

  config = lib.mkIf cfg.enable {
    # System Optimizations
    programs.gamemode.enable = cfg.optimizations;
    programs.gamescope.enable = cfg.optimizations;

    # Steam Integration (automatically enabled with steam)
    programs.steam = lib.mkIf hasSteam {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = cfg.optimizations;
    };

    # Controller Driver Toggles
    hardware.xone.enable = cfg.controllers;
    hardware.xpadneo.enable = cfg.controllers;
    services.udev.packages = lib.optionals cfg.controllers [ pkgs.dualsensectl ];

    # Auto-install Flatpaks (safely deduplicated)
    services.flatpak.packages = lib.unique (
      lib.optional hasModrinth "com.modrinth.ModrinthApp"
      ++ lib.optional hasSober "org.vinegarhq.Sober"
    );

    # Package Resolutions
    environment.systemPackages =
      (resolveApps launcherMap cfg.launchers)
      ++ (resolveApps minecraftMap cfg.minecraft)
      ++ (resolveApps emulatorMap cfg.emulators)
      ++ (resolveApps toolMap cfg.tools);
  };
}