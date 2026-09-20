{ config, pkgs, lib, inputs, ... }:

let
  cfg = config.orbitos.shells.dms;
  isCurrentShell = config.orbitos.desktop.shell == "dms";
in
{
  options.orbitos.shells.dms = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the DankMaterialShell (DMS).";
    };

    enableDynamicTheming = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable matugen.";
    };

    enableSystemMonitoring = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable system monitoring widgets (dgop).";
    };

    enableAudioWavelength = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable audio visualizer widgets (cava).";
    };

    enableVPN = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable VPN management widget.";
    };

    enableCalendarEvents = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable calendar integration (khal).";
    };

    systemd = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable systemd user service for auto-start (disabled by default in favor of OrbitOS unified launcher).";
    };

    plugins = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Declarative DankMaterialShell plugins configuration.";
    };
  };

  config = lib.mkIf (cfg.enable || isCurrentShell) {
    programs.dank-material-shell = {
      enable = true;
      quickshell.package = lib.mkForce (lib.lowPrio (inputs.dms.packages.${pkgs.system}.quickshell or pkgs.quickshell));
      systemd.enable = cfg.systemd;
      enableDynamicTheming = cfg.enableDynamicTheming;
      enableSystemMonitoring = cfg.enableSystemMonitoring;
      enableAudioWavelength = cfg.enableAudioWavelength;
      enableVPN = cfg.enableVPN;
      enableCalendarEvents = cfg.enableCalendarEvents;
      plugins = cfg.plugins;
    };

    home.sessionVariables = lib.mkIf isCurrentShell {
      qsConfig = "dms";
    };
  };
}
